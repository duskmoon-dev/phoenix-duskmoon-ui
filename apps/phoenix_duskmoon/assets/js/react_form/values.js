export function pathOf(name) {
  return Array.isArray(name) ? name : String(name).replace(/\]/g, "").split(/[.[\]]/).filter(Boolean);
}

export function fieldKey(name) { return pathOf(name).join("."); }

export function getAt(values, name) {
  return pathOf(name).reduce((current, key) => current?.[key], values);
}

export function setAt(values, name, value) {
  const path = pathOf(name);
  const result = structuredClone(values);
  let current = result;
  path.slice(0, -1).forEach((key) => { current[key] ??= {}; current = current[key]; });
  current[path.at(-1)] = value;
  return result;
}

export function collectValues(elements) {
  return elements.reduce((values, element) => {
    let value;
    if (element.type === "checkbox") value = Boolean(element.checked);
    else if (element.type === "number") value = element.value === "" ? null : Number(element.value);
    else if (element.multiple) value = [...element.selectedOptions].map((option) => option.value);
    else value = element.value;
    return setAt(values, element.name, value);
  }, {});
}
