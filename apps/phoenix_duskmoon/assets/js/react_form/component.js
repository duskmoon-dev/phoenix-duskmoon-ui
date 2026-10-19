import React, { useId } from "react";
import { Form } from "@duskmoon-dev/components/form";
import { Input } from "@duskmoon-dev/components/input";
import { InputNumber } from "@duskmoon-dev/components/input-number";
import { Checkbox } from "@duskmoon-dev/components/checkbox";
import { Select } from "@duskmoon-dev/components/select";

const h = React.createElement;

export function ReactField({ config, value, errors, disabled, onChange }) {
  const errorId = useId();
  const label = config.label || (Array.isArray(config.name) ? config.name.join(".") : config.name);
  const common = { disabled: Boolean(disabled || config.disabled), "aria-label": label, "aria-invalid": errors?.length ? "true" : undefined, "aria-describedby": errors?.length ? errorId : undefined };
  const textAttributes = { placeholder: config.placeholder ?? undefined, autoComplete: config.autocomplete ?? undefined, required: config.required, readOnly: config.readonly };
  let control;

  switch (config.type) {
    case "checkbox":
      control = h(Checkbox, { ...common, required: config.required, checked: Boolean(value), onChange: (event) => onChange(event.target.checked) });
      break;
    case "number":
      control = h(InputNumber, { ...common, ...textAttributes, min: config.min ?? undefined, max: config.max ?? undefined, step: config.step ?? undefined,
        value: value ?? null, onChange });
      break;
    case "select":
    case "multiselect":
      control = h(Select, { ...common, placeholder: config.placeholder ?? undefined, "aria-required": config.required ? "true" : undefined,
        value: value ?? undefined, mode: config.type === "multiselect" ? "multiple" : undefined,
        options: config.options || [], showSearch: true, allowClear: true, onChange: (next) => onChange(next ?? null) });
      break;
    case "textarea":
      control = h("textarea", { ...common, ...textAttributes, rows: config.rows ?? undefined, className: "textarea", value: value ?? "", onChange: (event) => onChange(event.target.value) });
      break;
    default:
      control = h(Input, { ...common, ...textAttributes, type: config.type, value: value ?? "", onChange: (event) => onChange(event.target.value) });
  }

  return h(Form.Item, {
    label,
    required: config.required,
    className: errors?.length ? "form-item-error" : undefined,
    help: errors?.length ? h(Form.ErrorList, { id: errorId, errors, role: "alert" }) : undefined,
  }, control);
}
