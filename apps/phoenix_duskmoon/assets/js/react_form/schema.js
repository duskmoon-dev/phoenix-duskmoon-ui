import React from "react";
import { JsonSchemaForm } from "@duskmoon-dev/components/json-schema-form";
import { pathOf } from "./values.js";

export function ReactSchemaForm({ disabled, ...props }) {
	return React.createElement(
		"fieldset",
		{ disabled },
		React.createElement(JsonSchemaForm, props),
	);
}

// The public renderer reports a whole value tree; preserve the narrowest changed path.
export function changedPath(previous, next, path = []) {
	if (
		!previous ||
		!next ||
		typeof previous !== "object" ||
		typeof next !== "object"
	)
		return path;
	const keys = [
		...new Set([...Object.keys(previous), ...Object.keys(next)]),
	].filter(
		(key) => JSON.stringify(previous[key]) !== JSON.stringify(next[key]),
	);
	return keys.length === 1
		? changedPath(previous[keys[0]], next[keys[0]], [...path, keys[0]])
		: path;
}

// Accept existing nested/dotted LiveView errors and the renderer's JSON Pointer errors.
export function schemaErrors(errors, path = [], result = {}) {
	Object.entries(errors || {}).forEach(([key, value]) => {
		const parts = [
			...path,
			...(!path.length && !key.startsWith("/") ? pathOf(key) : [key]),
		];
		const pointer =
			!path.length && (key === "" || key.startsWith("/"))
				? key
				: `/${parts.map((part) => String(part).replaceAll("~", "~0").replaceAll("/", "~1")).join("/")}`;
		if (typeof value === "string") result[pointer] = value;
		else if (
			Array.isArray(value) &&
			value.every((message) => typeof message === "string")
		) {
			if (value.length) result[pointer] = value.join("; ");
		} else if (value && typeof value === "object")
			schemaErrors(value, parts, result);
	});
	return result;
}
