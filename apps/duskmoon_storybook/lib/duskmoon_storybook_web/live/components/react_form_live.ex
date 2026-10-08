defmodule DuskmoonStorybookWeb.Components.ReactFormLive do
  @moduledoc "Interactive UI demo for the React-owned JSON form."

  use DuskmoonStorybookWeb, :live_view

  @form_id "react-profile"
  @schema_form_id "react-schema-profile"

  @impl true
  def mount(_params, _session, socket) do
    values = default_values()

    {:ok,
     assign(socket,
       form_id: @form_id,
       values: values,
       submitted: nil,
       event_count: 0,
       revision: 0,
       status: "Waiting for a change",
       last_changed: "-",
       payload_size: byte_size(Jason.encode!(values)),
       schema: profile_schema(),
       schema_submitted: nil,
       schema_revision: 0,
       schema_changed: "-",
       schema_status: "Schema defaults ready"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full max-w-7xl p-4 md:p-8">
      <.dm_breadcrumb class="mb-6">
        <:crumb to={~p"/components"}>Components</:crumb>
        <:crumb to={~p"/components/data-entry/react-form"}>Data Entry</:crumb>
        <:crumb>React Form</:crumb>
      </.dm_breadcrumb>

      <header class="mb-8">
        <div class="mb-3 flex flex-wrap items-center gap-2">
          <.dm_badge variant="secondary">React integration</.dm_badge>
          <span class="text-sm opacity-60">dm_react_form + dm_react_field</span>
        </div>
        <h1 class="text-4xl font-bold tracking-tight">React JSON form</h1>
        <p class="mt-3 max-w-3xl text-base opacity-70">
          A nested form that mixes React-managed fields with native HTML controls. Change events
          send typed JSON and a changed path; the server validates it and returns structured errors.
        </p>
      </header>

      <div class="grid gap-6 xl:grid-cols-[minmax(0,1fr)_22rem]">
        <section class="card border border-base-300 bg-base-100 shadow-sm">
          <div class="card-body p-4 md:p-6">
            <div class="mb-5 flex items-center justify-between gap-4">
              <div>
                <h2 class="text-xl font-semibold">Profile editor</h2>
                <p class="text-sm opacity-60">Try invalid values to see field-level replies.</p>
              </div>
              <span class="font-mono text-xs opacity-50">revision: {@revision}</span>
            </div>

            <.dm_react_form
              id={@form_id}
              values={@values}
              phx-change="validate-profile"
              phx-submit="save-profile"
              phx-debounce="180"
              class="max-w-4xl"
            >
              <div class="grid gap-6">
                <section>
                  <h3 class="mb-3 text-lg font-semibold">Identity</h3>
                  <div class="grid gap-4 md:grid-cols-2">
                    <.dm_react_field name={[:profile, :name]} type="text" label="Display name" />
                    <.dm_react_field name={[:profile, :email]} type="email" label="Email" />
                    <.dm_react_field
                      name={[:profile, :role]}
                      type="select"
                      label="Role"
                      options={role_options()}
                    />
                    <.dm_react_field name={[:profile, :seats]} type="number" label="Seats" />
                  </div>
                </section>

                <section>
                  <h3 class="mb-3 text-lg font-semibold">Preferences</h3>
                  <div class="grid gap-4 md:grid-cols-2">
                    <.dm_react_field
                      name={[:preferences, :channels]}
                      type="multiselect"
                      label="Notification channels"
                      options={channel_options()}
                    />
                    <label class="flex items-center gap-3 rounded-lg border border-base-300 p-3">
                      <input
                        name="preferences[newsletter]"
                        type="checkbox"
                        checked={@values["preferences"]["newsletter"]}
                        class="checkbox"
                      />
                      <span>
                        <span class="block font-medium">Weekly newsletter</span>
                        <span class="block text-sm opacity-60">Native HTML control in the same JSON tree</span>
                      </span>
                    </label>
                  </div>
                </section>

                <label class="form-control">
                  <span class="label-text mb-2 font-medium">Notes</span>
                  <textarea
                    name="notes"
                    class="textarea textarea-bordered min-h-28"
                    placeholder="Add context for the team"
                  >{@values["notes"]}</textarea>
                </label>

                <div class="flex flex-wrap gap-3">
                  <button type="submit" class="btn btn-primary">Save profile</button>
                  <button
                    id="form-reset"
                    type="button"
                    class="btn btn-outline"
                    phx-click="reset-profile"
                  >
                    Reset local draft
                  </button>
                </div>
              </div>
            </.dm_react_form>
          </div>
        </section>

        <aside class="flex flex-col gap-4">
          <section class="card border border-base-300 bg-base-100 shadow-sm">
            <div class="card-body gap-4 p-5">
              <h2 class="text-lg font-semibold">Transport monitor</h2>
              <div class="grid grid-cols-2 gap-3">
                <div class="rounded-lg bg-base-200 p-3">
                  <p class="text-xs uppercase tracking-wide opacity-60">Events</p>
                  <p id="form-event-count" class="mt-1 text-2xl font-bold">{@event_count}</p>
                </div>
                <div class="rounded-lg bg-base-200 p-3">
                  <p class="text-xs uppercase tracking-wide opacity-60">Payload</p>
                  <p id="form-payload-size" class="mt-1 text-2xl font-bold">{@payload_size} B</p>
                </div>
              </div>
              <p id="form-status" class="text-sm opacity-70">{@status}</p>
              <p class="font-mono text-xs opacity-50">Changed: {@last_changed}</p>
            </div>
          </section>

          <section class="card border border-base-300 bg-base-100 shadow-sm">
            <div class="card-body gap-3 p-5">
              <h2 class="text-lg font-semibold">Preset values</h2>
              <button
                id="form-preset-minimal"
                type="button"
                class="btn btn-outline w-full"
                phx-click="load-preset"
                phx-value-preset="minimal"
              >
                Load minimal preset
              </button>
              <button
                id="form-preset-team"
                type="button"
                class="btn btn-outline w-full"
                phx-click="load-preset"
                phx-value-preset="team"
              >
                Load team preset
              </button>
              <p class="text-xs opacity-60">
                Presets use the explicit <code>dm:form:reset</code> event because the form subtree
                is intentionally ignored by LiveView after React mounts it.
              </p>
            </div>
          </section>

          <section class="card border border-base-300 bg-base-100 shadow-sm">
            <div class="card-body p-5">
              <h2 class="mb-3 text-lg font-semibold">Last saved JSON</h2>
              <pre
                id="form-payload-preview"
                class="max-h-64 overflow-auto rounded-lg bg-base-200 p-3 text-xs"
              >{if @submitted, do: Jason.encode!(@submitted, pretty: true), else: "No submit yet"}</pre>
            </div>
          </section>
        </aside>
      </div>

      <section class="card mt-8 border border-base-300 bg-base-100 shadow-sm">
        <div class="card-body p-4 md:p-6">
          <h2 class="text-xl font-semibold">JSON Schema profile</h2>
          <p class="max-w-3xl text-sm opacity-70">
            Pass a schema to dm_react_form to generate controls without field slots.
            This form includes a nested object, editable member array, numeric plan enum,
            required fields, and typed defaults. React validates the schema; the server
            checks name availability. Try the workspace name "taken" for a backend error.
          </p>
          <.dm_react_form
            id="react-schema-profile"
            schema={@schema}
            phx-change="validate-schema-profile"
            phx-submit="save-schema-profile"
            phx-debounce="180"
            class="max-w-4xl"
          />
          <div class="flex flex-wrap items-center gap-4">
            <button
              id="schema-form-preset"
              type="button"
              class="btn btn-outline"
              phx-click="load-schema-preset"
            >
              Load schema preset
            </button>
            <p id="schema-form-status" class="text-sm opacity-70">{@schema_status}</p>
            <p class="font-mono text-xs opacity-60">
              Revision: <span id="schema-form-revision">{@schema_revision}</span>
            </p>
            <p class="font-mono text-xs opacity-60">
              Changed: <span id="schema-form-changed">{@schema_changed}</span>
            </p>
          </div>
          <h3 class="font-semibold">Last saved schema JSON</h3>
          <pre
            id="schema-form-payload-preview"
            class="max-h-64 overflow-auto rounded-lg bg-base-200 p-3 text-xs"
          >{if @schema_submitted, do: Jason.encode!(@schema_submitted, pretty: true), else: "No schema submit yet"}</pre>
        </div>
      </section>
    </div>
    """
  end

  @impl true
  def handle_event("validate-profile", params, socket) do
    values = Map.get(params, "values", %{})
    errors = validation_errors(values)
    changed = params |> Map.get("changed", []) |> Enum.join(".")
    revision = Map.get(params, "revision", socket.assigns.revision)

    reply =
      if map_size(errors) == 0 do
        %{status: "ok"}
      else
        %{status: "error", errors: errors}
      end

    {:reply, reply,
     assign(socket,
       event_count: socket.assigns.event_count + 1,
       revision: revision,
       status: if(map_size(errors) == 0, do: "Valid draft", else: "Validation errors returned"),
       last_changed: if(changed == "", do: "-", else: changed),
       payload_size: byte_size(Jason.encode!(values))
     )}
  end

  def handle_event("save-profile", params, socket) do
    values = Map.get(params, "values", %{})
    errors = validation_errors(values)
    revision = Map.get(params, "revision", socket.assigns.revision)

    if map_size(errors) > 0 do
      {:reply, %{status: "error", errors: errors},
       assign(socket, status: "Fix validation errors first", revision: revision)}
    else
      {:reply, %{status: "ok", message: "Profile saved"},
       assign(socket,
         submitted: values,
         event_count: socket.assigns.event_count + 1,
         revision: revision,
         status: "Profile saved successfully",
         last_changed: "submit",
         payload_size: byte_size(Jason.encode!(values))
       )}
    end
  end

  def handle_event("load-preset", %{"preset" => preset}, socket) do
    {values, status} =
      case preset do
        "team" -> {team_values(), "Loaded team preset"}
        _ -> {minimal_values(), "Loaded minimal preset"}
      end

    {:noreply, reset_form(socket, values, status)}
  end

  def handle_event("reset-profile", _params, socket),
    do: {:noreply, reset_form(socket, default_values(), "Draft reset")}

  def handle_event("validate-schema-profile", params, socket) do
    errors = schema_errors(params["values"])

    {:reply, schema_reply(errors),
     assign(socket,
       schema_revision: params["revision"],
       schema_changed: Enum.join(params["changed"] || [], "."),
       schema_status:
         if(errors == %{}, do: "Valid schema draft", else: "Name availability error returned")
     )}
  end

  def handle_event("save-schema-profile", params, socket) do
    errors = schema_errors(params["values"])

    if errors == %{} do
      {:reply, %{status: "ok", message: "Schema profile saved"},
       assign(socket,
         schema_submitted: params["values"],
         schema_revision: params["revision"],
         schema_status: "Schema profile saved successfully"
       )}
    else
      {:reply, schema_reply(errors),
       assign(socket,
         schema_revision: params["revision"],
         schema_status: "Choose another workspace name"
       )}
    end
  end

  def handle_event("load-schema-preset", _params, socket) do
    values = %{
      "profile" => %{
        "name" => "Platform team",
        "plan" => 3,
        "seats" => 12,
        "notifications" => false
      },
      "members" => [%{"email" => "team@example.test"}, %{"email" => "ops@example.test"}]
    }

    {:noreply,
     push_event(socket, "dm:form:reset", %{id: @schema_form_id, values: values})
     |> assign(
       schema_revision: socket.assigns.schema_revision + 1,
       schema_changed: "preset",
       schema_status: "Loaded schema preset"
     )}
  end

  defp schema_errors(values) do
    if get_in(values, ["profile", "name"]) == "taken",
      do: %{"/profile/name" => "Workspace name is already reserved"},
      else: %{}
  end

  defp schema_reply(errors) when errors == %{}, do: %{status: "ok"}
  defp schema_reply(errors), do: %{status: "error", errors: errors}

  defp profile_schema do
    %{
      "type" => "object",
      "required" => ["profile", "members"],
      "properties" => %{
        "profile" => %{
          "type" => "object",
          "title" => "Workspace",
          "required" => ["name", "plan", "seats"],
          "properties" => %{
            "name" => %{
              "type" => "string",
              "title" => "Workspace name",
              "minLength" => 1,
              "default" => "Moonlight team"
            },
            "plan" => %{
              "type" => "integer",
              "title" => "Plan",
              "enum" => [1, 2, 3],
              "default" => 2,
              "x-widget" => "select",
              "x-options" => [
                %{"value" => 1, "label" => "Starter"},
                %{"value" => 2, "label" => "Team"},
                %{"value" => 3, "label" => "Enterprise"}
              ]
            },
            "seats" => %{"type" => "integer", "title" => "Seats", "minimum" => 1, "default" => 3},
            "notifications" => %{
              "type" => "boolean",
              "title" => "Email notifications",
              "default" => true
            }
          }
        },
        "members" => %{
          "type" => "array",
          "title" => "Members",
          "minItems" => 1,
          "default" => [%{"email" => "ada@example.test"}],
          "items" => %{
            "type" => "object",
            "required" => ["email"],
            "properties" => %{
              "email" => %{"type" => "string", "title" => "Member email", "format" => "email"}
            }
          }
        }
      }
    }
  end

  defp reset_form(socket, values, status) do
    push_event(socket, "dm:form:reset", %{id: @form_id, values: values})
    |> assign(
      values: values,
      event_count: socket.assigns.event_count + 1,
      revision: socket.assigns.revision + 1,
      status: status,
      last_changed: "preset",
      payload_size: byte_size(Jason.encode!(values))
    )
  end

  defp validation_errors(values) do
    profile = Map.get(values, "profile", %{})
    name = String.trim(to_string(Map.get(profile, "name", "")))
    email = String.trim(to_string(Map.get(profile, "email", "")))
    seats = Map.get(profile, "seats")

    %{}
    |> maybe_error("profile.name", name == "", "Display name is required")
    |> maybe_error("profile.email", !String.contains?(email, "@"), "Enter a valid email")
    |> maybe_error("profile.seats", !is_number(seats) or seats < 1, "Seats must be at least 1")
  end

  defp maybe_error(errors, _key, false, _message), do: errors
  defp maybe_error(errors, key, true, message), do: Map.put(errors, key, [message])

  defp default_values do
    %{
      "profile" => %{
        "name" => "Ada Lovelace",
        "email" => "ada@example.test",
        "role" => "editor",
        "seats" => 4
      },
      "preferences" => %{"channels" => ["email", "slack"], "newsletter" => true},
      "notes" => "Uses nested fields and native HTML together."
    }
  end

  defp minimal_values do
    put_in(default_values(), ["profile", "name"], "New teammate")
    |> put_in(["profile", "email"], "new@example.test")
    |> put_in(["profile", "seats"], 1)
    |> put_in(["preferences", "channels"], ["email"])
  end

  defp team_values do
    put_in(default_values(), ["profile", "name"], "Platform team")
    |> put_in(["profile", "role"], "admin")
    |> put_in(["profile", "seats"], 24)
    |> put_in(["preferences", "channels"], ["email", "slack", "webhook"])
  end

  defp role_options,
    do: [
      %{value: "viewer", label: "Viewer"},
      %{value: "editor", label: "Editor"},
      %{value: "admin", label: "Admin"}
    ]

  defp channel_options,
    do: [
      %{value: "email", label: "Email"},
      %{value: "slack", label: "Slack"},
      %{value: "webhook", label: "Webhook"}
    ]
end
