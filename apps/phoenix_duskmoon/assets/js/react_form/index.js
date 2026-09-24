import React from "react";
import { createRoot } from "react-dom/client";
import { ReactField } from "./component.js";
import { collectValues, fieldKey, getAt, pathOf, setAt } from "./values.js";
function parseJSON(value, fallback = {}) { try { return JSON.parse(value); } catch { return fallback; } }
function flattenErrors(errors, prefix = [], result = {}) {
  Object.entries(errors || {}).forEach(([key, value]) => {
    const path = [...prefix, key];
    if (Array.isArray(value)) result[path.join(".")] = value;
    else if (value && typeof value === "object") flattenErrors(value, path, result);
  });
  return result;
}

export const DuskmoonReactForm = {
  mounted() {
    this.form = this.el.querySelector("[data-dm-react-form]");
    const nativeValues = collectValues([...this.form.querySelectorAll("[name]")]);
    this.values = { ...nativeValues, ...parseJSON(this.el.dataset.initialValues) };
    this.initialValues = structuredClone(this.values);
    this.revision = 0; this.roots = new Map(); this.disconnectedState = false;
    this.fields = [...this.el.querySelectorAll("[data-dm-react-field]")];
    const fieldKeys = this.fields.map((element) => fieldKey(parseJSON(element.dataset.dmReactField).name));
    if (new Set(fieldKeys).size !== fieldKeys.length) throw new Error("React form field names must be unique");
    this.mountFields(); this.bindNative(); this.bindForm();
    this.handleEvent("dm:form:reset", (payload) => {
      if (payload?.id === this.el.id) this.resetForm(payload.values ?? this.initialValues);
    });
  },

  mountFields() {
    this.fields.forEach((element) => {
      const config = parseJSON(element.dataset.dmReactField);
      const key = fieldKey(config.name); const root = createRoot(element);
      this.roots.set(key, { config, root }); this.renderField(element);
    });
  },
  renderField(element) {
    const config = parseJSON(element.dataset.dmReactField); const entry = this.roots.get(fieldKey(config.name));
    entry?.root.render(React.createElement(ReactField, {
      config, value: getAt(this.values, config.name), errors: this.errors?.[fieldKey(config.name)], disabled: this.disconnectedState,
      onChange: (value) => this.change(config.name, value),
    }));
  },
  bindNative() {
    this.native = [...this.form.querySelectorAll("[name]")].filter((element) => !element.closest("[data-dm-react-field]"));
    this.native.forEach((element) => {
      const handler = () => this.change(element.name, this.nativeValue(element));
      element.addEventListener("input", handler); element.addEventListener("change", handler); element.__dmReactHandler = handler;
    });
  },
  nativeValue(element) {
    if (element.type === "checkbox") return element.checked;
    if (element.type === "number") return element.value === "" ? null : Number(element.value);
    if (element.multiple) return [...element.selectedOptions].map((option) => option.value);
    return element.value;
  },
  bindForm() {
    this.submitHandler = (event) => { event.preventDefault(); this.submit(); };
    this.resetHandler = () => setTimeout(() => this.resetForm(), 0);
    this.form.addEventListener("submit", this.submitHandler); this.form.addEventListener("reset", this.resetHandler);
  },
  change(name, value) {
    this.values = setAt(this.values, name, value); this.errors = { ...this.errors, [fieldKey(name)]: [] }; this.renderAll();
    const event = this.el.getAttribute("phx-change"); if (!event || this.disconnectedState) return;
    clearTimeout(this.changeTimer); this.changeTimer = setTimeout(() => this.send(event, name), Number(this.el.getAttribute("phx-debounce") || 0));
  },
  submit() { clearTimeout(this.changeTimer); const event = this.el.getAttribute("phx-submit"); if (event && !this.disconnectedState) this.send(event); },
  send(event, changed) {
    const revision = ++this.revision; const payload = { id: this.el.id, values: this.values, revision, ...(changed ? { changed: pathOf(changed) } : {}) };
    const target = this.el.getAttribute("phx-target"); const callback = (reply) => {
      if (revision !== this.revision || !reply) return; this.errors = flattenErrors(reply.errors); this.renderAll();
    };
    if (target) this.pushEventTo(target, event, payload, callback); else this.pushEvent(event, payload, callback);
  },
  renderAll() { this.fields.forEach((element) => this.renderField(element)); },
  resetForm(values = this.initialValues) {
    this.values = structuredClone(values); this.errors = {}; this.revision++;
    this.native.forEach((element) => { if (element.type === "checkbox") element.checked = Boolean(getAt(this.values, element.name)); else element.value = getAt(this.values, element.name) ?? ""; }); this.renderAll();
  },
  disconnected() { this.disconnectedState = true; this.renderAll(); },
  reconnected() { this.disconnectedState = false; this.renderAll(); },
  destroyed() { clearTimeout(this.changeTimer); this.form.removeEventListener("submit", this.submitHandler); this.form.removeEventListener("reset", this.resetHandler); this.native.forEach((element) => { element.removeEventListener("input", element.__dmReactHandler); element.removeEventListener("change", element.__dmReactHandler); }); this.roots.forEach(({ root }) => root.unmount()); },
};
