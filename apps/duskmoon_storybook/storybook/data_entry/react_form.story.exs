defmodule Storybook.DataEntry.ReactForm do
  use PhoenixStorybook.Story, :example
  import PhoenixDuskmoon.Component.DataEntry.ReactForm

  def doc, do: "Nested HEEX with native HTML and React-managed fields submitted as typed JSON."
  @impl true
  def mount(_, _, socket), do: {:ok, assign(socket, :submitted, nil)}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6 bg-surface text-on-surface">
      <h2 class="text-xl font-bold">React JSON Form</h2>
      <.dm_react_form
        id="react-profile"
        values={defaults()}
        phx-change="validate-profile"
        phx-submit="save-profile"
        phx-debounce="300"
        class="max-w-lg mt-4"
      >
        <div class="grid gap-4">
          <.dm_react_field name="name" type="text" label="Name" />
          <div class="grid grid-cols-2 gap-4">
            <.dm_react_field name="seats" type="number" label="Seats" />
            <.dm_react_field name="roles" type="multiselect" label="Roles" options={role_options()} />
          </div>
          <label class="flex gap-2 items-center"><input
            name="notes"
            class="input"
            value="Native HTML note"
          /> Notes</label>
          <button type="submit" class="btn btn-primary">Save</button>
          <button type="reset" class="btn btn-outline">Reset</button>
        </div>
      </.dm_react_form>
      <pre id="received-json" class="p-4 mt-4 bg-surface-container rounded">{if @submitted, do: Jason.encode!(@submitted, pretty: true), else: "No submission yet"}</pre>
    </div>
    """
  end

  @impl true
  def handle_event("validate-profile", %{"values" => values}, socket) do
    if values["name"] == "taken",
      do: {:reply, %{status: "error", errors: %{name: ["Already used"]}}, socket},
      else: {:reply, %{status: "ok"}, socket}
  end

  @impl true
  def handle_event("save-profile", %{"values" => values}, socket),
    do: {:reply, %{status: "ok", message: "Saved"}, assign(socket, :submitted, values)}

  defp defaults, do: %{name: "Ada", seats: 2, roles: ["reader"]}

  defp role_options,
    do: [
      %{value: "reader", label: "Reader"},
      %{value: "editor", label: "Editor"},
      %{value: "admin", label: "Admin"}
    ]
end
