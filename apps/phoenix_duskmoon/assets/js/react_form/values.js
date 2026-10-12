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

function isCheckboxGroup(element) {
  return element.type === "checkbox" && element.name.endsWith("[]");
}

export function nativeValue(element, elements = [element]) {
  if (isCheckboxGroup(element)) {
    return elements.filter((control) => control.type === "checkbox" && control.name === element.name && control.checked)
      .map((control) => control.value);
  }
  if (element.type === "checkbox") return Boolean(element.checked);
  if (element.type === "number") return element.value === "" ? null : Number(element.value);
  if (element.multiple) return [...element.selectedOptions].map((option) => option.value);
  return element.value;
}

export function setNativeValue(element, value) {
  if (element.type === "checkbox") {
    element.checked = isCheckboxGroup(element) ? Array.isArray(value) && value.includes(element.value) : Boolean(value);
  } else element.value = value ?? "";
}

export function collectValues(elements) {
  return elements.reduce((values, element) => setAt(values, element.name, nativeValue(element, elements)), {});
}
