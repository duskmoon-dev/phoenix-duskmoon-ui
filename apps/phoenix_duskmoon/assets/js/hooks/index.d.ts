export type HookEventPayload = unknown;

export type HookEventCallback = (reply: unknown, ref: number) => void;

/** The LiveView-owned context supplied as `this` to hook callbacks. */
export interface LiveViewHookContext<ElementType extends HTMLElement = HTMLElement> {
	readonly el: ElementType;
	handleEvent(
		event: string,
		callback: (payload: HookEventPayload) => void,
	): unknown;
	pushEvent(
		event: string,
		payload?: HookEventPayload,
		callback?: HookEventCallback,
	): unknown;
	pushEventTo(
		target: string | number | HTMLElement,
		event: string,
		payload?: HookEventPayload,
		callback?: HookEventCallback,
	): unknown;
}

/** A Phoenix LiveView hook definition object. */
export interface LiveViewHook<ElementType extends HTMLElement = HTMLElement> {
	mounted?(this: LiveViewHookContext<ElementType>): void;
	updated?(this: LiveViewHookContext<ElementType>): void;
	destroyed?(this: LiveViewHookContext<ElementType>): void;
}

/** Universal LiveView to custom-element event bridge. */
export declare const WebComponentHook: LiveViewHook;

/** WebComponentHook with Phoenix form-feedback integration. */
export declare const FormElementHook: LiveViewHook;

/** Theme toggle with localStorage persistence. */
export declare const ThemeSwitcher: LiveViewHook<HTMLDetailsElement>;

/** Cmd/Ctrl+K spotlight dialog keyboard handler. */
export declare const Spotlight: LiveViewHook<HTMLDialogElement>;

/** Page-header visibility observer. */
export declare const PageHeader: LiveViewHook;

/** Synchronizes an explicitly controlled native popover with LiveView state. */
export declare const DuskmoonPopover: LiveViewHook<HTMLElement>;
