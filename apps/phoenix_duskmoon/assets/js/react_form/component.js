import React from "react";
import { Input } from "@duskmoon-dev/components/input";
import { InputNumber } from "@duskmoon-dev/components/input-number";
import { Checkbox } from "@duskmoon-dev/components/checkbox";
import { Select } from "@duskmoon-dev/components/select";

const h = React.createElement;

export function ReactField({ config, value, errors, disabled, onChange }) {
  const label = config.label || (Array.isArray(config.name) ? config.name.join(".") : config.name);
  const common = { disabled, "aria-label": label, "aria-invalid": errors?.length ? "true" : undefined };
  let control;

  switch (config.type) {
    case "checkbox":
      control = h(Checkbox, { ...common, checked: Boolean(value), onChange: (event) => onChange(event.target.checked) });
      break;
    case "number":
      control = h(InputNumber, { ...common, value: value ?? null, onChange });
      break;
    case "select":
    case "multiselect":
      control = h(Select, { ...common, value: value ?? undefined, mode: config.type === "multiselect" ? "multiple" : undefined,
        options: config.options || [], showSearch: true, allowClear: true, onChange: (next) => onChange(next ?? null) });
      break;
    case "textarea":
      control = h("textarea", { ...common, className: "textarea", value: value ?? "", onChange: (event) => onChange(event.target.value) });
      break;
    default:
      control = h(Input, { ...common, type: config.type, value: value ?? "", onChange: (event) => onChange(event.target.value) });
  }

  return h("label", { className: "form-item" },
    label && h("span", { className: "form-item-label" }, label),
    control,
    errors?.map((error, index) => h("span", { className: "form-item-help form-item-error", role: "alert", key: index }, error)));
}
