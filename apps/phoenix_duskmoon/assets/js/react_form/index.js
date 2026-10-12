import React from "react";
import { createRoot } from "react-dom/client";
import { ReactField } from "./component.js";
import { compileForm } from "@duskmoon-dev/components/json-schema-form";
import { ReactSchemaForm, changedPath, schemaErrors } from "./schema.js";
import { collectValues, fieldKey, getAt, nativeValue, pathOf, setAt, setNativeValue } from "./values.js";
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
    this.revision = 0; this.roots = new Map(); this.fields = []; this.disconnectedState = false;
    this.schemaElement = this.el.querySelector("[data-dm-react-schema]");
    if (this.schemaElement) this.mountSchema();
    else this.mountForm();
    this.handleEvent("dm:form:reset", (payload) => {
      if (payload?.id === this.el.id) this.resetForm(payload.values ?? this.initialValues);
    });
  },
  mountForm() {
    this.form = this.el.querySelector("[data-dm-react-form]");
    this.fields = [...this.el.querySelectorAll("[data-dm-react-field]")];
    const nativeValues = collectValues(this.nativeControls());
    this.values = { ...nativeValues, ...parseJSON(this.el.dataset.initialValues) };
    this.initialValues = structuredClone(this.values);
    const fieldKeys = this.fields.map((element) => fieldKey(parseJSON(element.dataset.dmReactField).name));
    if (new Set(fieldKeys).size !== fieldKeys.length) throw new Error("React form field names must be unique");
    this.mountFields(); this.bindNative(); this.bindForm();
  },
  mountSchema() {
    this.compiledSchema = compileForm(JSON.parse(this.el.dataset.schema));
    this.values = parseJSON(this.el.dataset.initialValues, this.compiledSchema.initialValue());
    this.initialValues = structuredClone(this.values);
    this.schemaRevision = 0; this.schemaRoot = createRoot(this.schemaElement);
    this.renderSchema();
  },
  renderSchema() {
    this.schemaRoot.render(React.createElement(ReactSchemaForm, {
      key: this.schemaRevision, compiled: this.compiledSchema, value: this.values,
      defaultValue: this.initialValues, errors: this.errors, disabled: this.disconnectedState,
      onChange: (values) => {
        const path = changedPath(this.values, values);
        this.values = structuredClone(values); this.errors = {}; this.renderAll(); this.scheduleChange(path);
      },
      onErrorsChange: () => { this.errors = {}; this.renderAll(); },
      onSubmit: (values) => { this.values = structuredClone(values); this.submit(); },
      onReset: () => this.resetForm(),
    }));
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
  nativeControls() {
    const managedPaths = this.fields.map((element) => pathOf(parseJSON(element.dataset.dmReactField).name).map(String));
    return [...this.form.querySelectorAll("input[name], select[name], textarea[name]")].filter((element) => {
      if (element.closest("[data-dm-react-field]")) return false;
      const path = pathOf(element.name).map(String);
      return !managedPaths.some((managed) => managed.slice(0, Math.min(path.length, managed.length)).every((key, index) => key === path[index]));
    });
  },
  bindNative() {
    this.nativeHandler = (event) => {
      const controls = this.nativeControls(); const element = event.target;
      if (controls.includes(element)) this.change(element.name, nativeValue(element, controls));
    };
    this.form.addEventListener("input", this.nativeHandler); this.form.addEventListener("change", this.nativeHandler);
  },
  nativeValue(element) {
    return nativeValue(element, this.nativeControls());
  },
  bindForm() {
    this.submitHandler = (event) => { event.preventDefault(); this.submit(); };
    this.resetHandler = () => setTimeout(() => this.resetForm(), 0);
    this.form.addEventListener("submit", this.submitHandler); this.form.addEventListener("reset", this.resetHandler);
  },
  change(name, value) {
    this.values = setAt(this.values, name, value); this.errors = { ...this.errors, [fieldKey(name)]: [] }; this.renderAll();
    this.scheduleChange(name);
  },
  scheduleChange(name) {
    const event = this.el.getAttribute("phx-change"); if (!event || this.disconnectedState) return;
    clearTimeout(this.changeTimer); this.changeTimer = setTimeout(() => this.send(event, name), Number(this.el.getAttribute("phx-debounce") || 0));
  },
  submit() {
    clearTimeout(this.changeTimer); const event = this.el.getAttribute("phx-submit"); if (!event || this.disconnectedState) return;
    if (this.form) {
      if (this.form.noValidate === false && !this.form.reportValidity()) return;
      const controls = this.nativeControls();
      controls.forEach((element) => { this.values = setAt(this.values, element.name, nativeValue(element, controls)); });
    }
    this.send(event);
  },
  send(event, changed) {
    const revision = ++this.revision; const values = this.values;
    const payload = { id: this.el.id, values, revision, ...(changed ? { changed: pathOf(changed) } : {}) };
    const target = this.el.getAttribute("phx-target"); const callback = (reply) => {
      if (this.destroyedState || revision !== this.revision || values !== this.values || !reply) return;
      this.errors = this.schemaRoot ? schemaErrors(reply.errors) : flattenErrors(reply.errors); this.renderAll();
    };
    if (target) this.pushEventTo(target, event, payload, callback); else this.pushEvent(event, payload, callback);
  },
  renderAll() { if (this.schemaRoot) this.renderSchema(); else this.fields.forEach((element) => this.renderField(element)); },
  resetForm(values = this.initialValues) {
    clearTimeout(this.changeTimer);
    this.values = structuredClone(values); this.errors = {}; this.revision++;
    if (this.schemaRoot) { this.schemaRevision++; this.renderAll(); return; }
    this.nativeControls().forEach((element) => setNativeValue(element, getAt(this.values, element.name))); this.renderAll();
  },
  disconnected() { clearTimeout(this.changeTimer); this.disconnectedState = true; this.renderAll(); },
  reconnected() { this.disconnectedState = false; this.renderAll(); },
  destroyed() { this.destroyedState = true; clearTimeout(this.changeTimer); this.schemaRoot?.unmount(); this.form?.removeEventListener("submit", this.submitHandler); this.form?.removeEventListener("reset", this.resetHandler); this.form?.removeEventListener("input", this.nativeHandler); this.form?.removeEventListener("change", this.nativeHandler); this.roots.forEach(({ root }) => root.unmount()); },
};
