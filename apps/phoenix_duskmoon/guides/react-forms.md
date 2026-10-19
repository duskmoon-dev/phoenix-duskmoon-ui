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

## Form layout

`class` belongs to the outer hook wrapper. Set `form_class` to put layout classes
on the actual classic form, whose direct children are your fields and actions:

```heex
<.dm_react_form id="create-skill" class="max-w-xl" form_class="flex flex-wrap gap-2 items-end" phx-submit="create-skill">
  <.dm_react_field name="name" label="Name" class="flex-1" />
  <.dm_react_field name="scope" type="select" label="Scope" options={[%{value: "global", label: "Global"}]} />
  <button type="submit" class="btn btn-primary">Create</button>
</.dm_react_form>
```

Both class attributes accept Phoenix class lists. `form_class` is omitted by
default. For vertical margin-based layouts such as `form_class="space-y-4"`, use
`class="block"` on direct `dm_react_field` children: their markers are inline
spans by default. Flex and grid layouts can use those markers directly as items.

In schema mode, `form_class` reaches the React-owned form through the published
`JsonSchemaForm.className` prop. Its default `form form-vertical schema-form`
classes are preserved. `class` still styles the outer wrapper. These presentation
attributes do not change LiveView events or ownership.

Marked fields use the published `@duskmoon-dev/components` 0.5.2 controls and
`Form.Item` presentation. Text, email, password, textarea, number, and checkbox
labels are associated with their input IDs. Select and multiselect labels and
error attributes reach their interactive trigger.
Server errors render through
`Form.ErrorList` as an alert referenced by the field's `aria-describedby`; fields
with errors also expose `aria-invalid`. Successful validation clears this state.

Use `type="number"` for numeric values (including zero, with an empty value as
`null`) and `type="checkbox"` for booleans. Select options accept string or numeric
values; `type="multiselect"` preserves the selected values as an array. Text,
email, password, and textarea fields retain string values.

## Field attributes

Pass supported control attributes directly to `dm_react_field`:

```heex
<.dm_react_field name="name" label="Name" required placeholder="Agent name" autocomplete="off" />
<.dm_react_field name="seats" type="number" label="Seats" min={1} max={100} step={1} />
<.dm_react_field name="reference" label="Reference" readonly />
<.dm_react_field name="notes" type="textarea" label="Notes" rows={4} />
```

| Attribute | Supported controls |
| --- | --- |
| `disabled` | All field types; combines with the disconnected state |
| `placeholder` | Text, email, password, textarea, number, select, multiselect |
| `autocomplete` | Text, email, password, textarea, number |
| `required` | Native input/textarea fields; select/multiselect use `aria-required` on the trigger |
| `readonly` | Text, email, password, textarea, number |
| `min`, `max`, `step` | Number bounds and stepping through upstream `InputNumber` |
| `rows` | Textarea |

These attributes reach the interactive control. Reconnection enables fields that
were disabled by the connection while preserving an application's `disabled` value.
`class` and remaining global attributes still belong to the field wrapper.
The form uses JSON submission and defaults to `novalidate`. Set
`novalidate={false}` for browser constraints before classic form submission, as
described below. Control attributes do not replace backend validation or authorization.

Components 0.5.2 handles numeric `readonly` across typing, keyboard stepping and
disabled step buttons, and forwards `aria-required` to selection triggers during
rendering. The earlier adapters for upstream [#82](https://github.com/duskmoon-dev/duskmoon-react/issues/82)
and [#83](https://github.com/duskmoon-dev/duskmoon-react/issues/83) are removed.

## LiveView events

React owns marked fields and serializes the complete value tree as JSON. Native
controls are collected by name using the same nested path rules. The LiveView
receives `%{"id" => id, "values" => values, "revision" => revision}` and a
change event also includes `"changed"` as a path list. Schema changes report the
narrowest common path, such as `["profile", "name"]` for a single field or `[]`
for a change across root properties. `phx-target` is passed to
the normal LiveView `pushEventTo` path.

Native input/change events are delegated from the form, so controls added or
replaced after mounting participate in change events. Submission reads current
native controls again, including hidden inputs updated programmatically without
an event. The snapshot preserves React-managed fields and native sibling paths;
native controls cannot overwrite a React-owned path or its ancestors. Controls
inside a React field are managed exclusively by React.

```heex
<.dm_react_form id="model-picker" phx-submit="save-model">
  <.dm_react_field name={[:agent, :name]} label="Agent name" />
  <input type="hidden" name="agent[provider]" value="default" />
  <button type="submit">Save</button>
</.dm_react_form>
```

A client hook can update or replace the hidden provider input; submission sends
its current value together with the React-managed agent name. Removing a native
control does not delete its previously collected value from the draft. Use
`dm:form:reset` to replace the draft explicitly.

## Browser constraints

Classic forms keep their existing `novalidate={true}` default. Opt into browser
constraint validation with `novalidate={false}`:

```heex
<.dm_react_form id="validated-profile" novalidate={false} phx-submit="save">
  <input name="title" required pattern="[A-Z]+" />
  <input name="email" type="email" required />
  <input name="importance" type="number" min="0" max="1" step="0.1" />
  <button type="submit">Save</button>
</.dm_react_form>
```

The hook calls the inner form's `reportValidity()` before sending a submit event.
Invalid controls receive browser feedback and block submission. Native `required`,
`pattern`, email format, numeric bounds and steps follow browser semantics;
rendered React inputs also participate where they expose native constraints.
Custom select triggers use required-state ARIA and need application validation.
Schema forms always use their JSON Schema validation; this classic-form option
does not change that contract. Validate and authorize submitted values on the backend.

## Native checkbox groups

Use a name ending in `[]` for native checkboxes that represent selected values.
Every checkbox in the group shares that name and supplies its own string `value`:

```heex
<.dm_react_form id="tools" phx-change="validate-tools" phx-submit="save-tools">
  <label><input type="checkbox" name="tool_names[]" value="file.read" checked /> Read files</label>
  <label><input type="checkbox" name="tool_names[]" value="file.write" /> Write files</label>
  <label><input type="checkbox" name="agent[toolset_ids][]" value="development" checked /> Development tools</label>
  <button type="submit">Save</button>
</.dm_react_form>
```

The initial JSON is `%{"tool_names" => ["file.read"], "agent" =>
%{"toolset_ids" => ["development"]}}`. Input and change events recompute the
selected values for the complete group; clearing its last selection sends `[]`.
The changed path excludes the array marker, for example `["agent", "toolset_ids"]`.
A group with one checkbox still uses an array. A checkbox without `[]` keeps its
boolean value, including `false` when unchecked.

`dm:form:reset` accepts arrays at these paths and restores each checkbox by
matching its `value`; an empty or omitted group value clears every checkbox.
The native Reset button restores the form's original values. Use native grouped
checkboxes for this representation; `dm_react_field type="checkbox"` remains a
single boolean field.

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

Components 0.5.0 requires Core 1.20.3 or newer and React/ReactDOM 19 or newer.
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
`form_class` adds classes to that generated form while preserving the upstream
layout classes, resolving [upstream #85](https://github.com/duskmoon-dev/duskmoon-react/issues/85).

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
