# React JSON forms

Use `dm_react_form` when a form needs rich client-side state from
`@duskmoon-dev/components`. Provide nested HEEX to mix normal HTML, Phoenix
components, loops, and conditionals with `dm_react_field`, or pass `schema` to
render the published JSON Schema form.

```heex
<.dm_react_form id="profile" values={@values} phx-change="validate" phx-submit="save" phx-debounce="300">
  <h2>Profile</h2>
  <.dm_react_field name="name" type="text" label="Name" />
  <.dm_react_field name={[:address, :city]} type="text" label="City" />
  <input name="notes" class="input" />
  <button type="submit" class="btn btn-primary">Save</button>
</.dm_react_form>
```

Marked fields use the published `@duskmoon-dev/components` 0.4.1 controls and
`Form.Item` presentation. Text, email, password, textarea, number, and checkbox
labels are associated with their input IDs. Select and multiselect labels and
error attributes reach their interactive trigger in Components 0.4.1.
Server errors render through
`Form.ErrorList` as an alert referenced by the field's `aria-describedby`; fields
with errors also expose `aria-invalid`. Successful validation clears this state.

Use `type="number"` for numeric values (including zero, with an empty value as
`null`) and `type="checkbox"` for booleans. Select options accept string or numeric
values; `type="multiselect"` preserves the selected values as an array. Text,
email, password, and textarea fields retain string values.

React owns marked fields and serializes the complete value tree as JSON. Native
controls are collected by name using the same nested path rules. The LiveView
receives `%{"id" => id, "values" => values, "revision" => revision}` and a
change event also includes `"changed"` as a path list. Schema changes report the
narrowest common path, such as `["profile", "name"]` for a single field or `[]`
for a change across root properties. `phx-target` is passed to
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

Components 0.4.1 requires Core 1.20.3 or newer and React/ReactDOM 19 or newer.
Keep the Components stylesheet import for its React form and control styles.

## Schema forms

`dm_react_form` accepts a schema map through the canonical form API:

```elixir
schema = %{
  type: "object",
  required: ["name"],
  properties: %{
    name: %{type: "string", title: "Name", minLength: 1},
    age: %{type: "integer", title: "Age", minimum: 0, default: 18},
    enabled: %{type: "boolean", title: "Enabled", default: false}
  }
}
```

```heex
<.dm_react_form id="schema-profile" schema={@schema} phx-change="validate" phx-submit="save" />
```

The hook mounts the public `JsonSchemaForm` and `compileForm` exports from
`@duskmoon-dev/components/json-schema-form`. The upstream renderer owns the
form, controls, Submit button, and Reset button. The Phoenix wrapper provides
an ignored mount boundary without a parent form. Optional HEEX slot content
appears beside the schema renderer, outside its form.

Omit `values` to use the compiled schema's initial values and defaults. Pass
`values={@values}` to start with an explicit typed JSON object; even `%{}` is an
explicit initial value. Classic HEEX forms still start with `%{}` when values
are omitted. The Reset form button restores the schema form's initial values. The
`dm:form:reset` event can replace the draft with backend-provided values.
The schema is fixed for each mount; use a new component ID when replacing it.

The renderer supports a strict JSON Schema draft 2020-12 subset: an object
root, nested objects, homogeneous arrays, string/number/integer/boolean fields,
primitive enums and defaults, `required`, `additionalProperties: false`,
string length/pattern/format constraints, numeric bounds and `multipleOf`, and
array/object size constraints. References, combinators, nullable types, and
arbitrary keywords are rejected. `x-widget`, `x-options`, and
`x-widget-options` select supported controls, typed options, and their documented
configuration. The compiler checks widget/type compatibility. Validation does
not coerce, remove, or insert defaults into submitted values.

Schema forms use the same LiveView JSON event/reply contract described above;
changes send the complete value object and its changed path. Submission
runs client validation before sending the typed object. Backend errors are
associated with nested fields; the upstream renderer uses escaped JSON Pointer
keys such as `/address/email`, with an empty key for a form-level error. Existing
nested changeset errors and dotted field names are converted to these pointers.
Backend authorization and validation remain required before persisting anything. Upload
widgets submit JSON file metadata; the application owns binary file transfer.
