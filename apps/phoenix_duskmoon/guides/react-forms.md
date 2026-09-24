# React JSON forms

Use `dm_react_form` when a form needs rich client-side state from
`@duskmoon-dev/components`. The form body remains nested HEEX, so normal HTML,
Phoenix components, loops, and conditionals can be mixed with `dm_react_field`.

```heex
<.dm_react_form id="profile" values={@values} phx-change="validate" phx-submit="save" phx-debounce="300">
  <h2>Profile</h2>
  <.dm_react_field name="name" type="text" label="Name" />
  <.dm_react_field name={[:address, :city]} type="text" label="City" />
  <input name="notes" class="input" />
  <button type="submit" class="btn btn-primary">Save</button>
</.dm_react_form>
```

React owns marked fields and serializes the complete value tree as JSON. Native
controls are collected by name using the same nested path rules. The LiveView
receives `%{"id" => id, "values" => values, "revision" => revision}` and a
change event also includes `"changed"` as a path list. `phx-target` is passed to
the normal LiveView `pushEventTo` path.

`phx-change` is debounced when `phx-debounce` is present. `phx-submit` sends the
latest snapshot immediately. Reply with `%{status: "ok"}` or
`%{status: "error", errors: %{field => [message]}}`; stale replies are ignored.
The backend remains authoritative and can reuse an Ecto changeset:

```elixir
changeset = Accounts.change_profile(profile, values) |> Map.put(:action, :validate)
{:reply, PhoenixDuskmoon.Component.DataEntry.ReactForm.validation_reply(changeset), socket}
```

Use `push_event(socket, "dm:form:reset", %{id: "profile", values: values})` to
replace the React draft and clear errors. React owns the ignored subtree after
mount, so server updates inside it require an explicit reset event. Existing
`dm_form` remains the Phoenix-native form for simple forms.
