/**
 * Phoenix Duskmoon UI v9 - Web Component Integration
 *
 * Provides LiveView hooks for bridging Phoenix LiveView events
 * with duskmoon-elements custom elements.
 */

/** Standard duskmoon-elements event names for automatic forwarding */
const DM_EVENTS = [
  "dm-click", "dm-change", "dm-input", "dm-focus", "dm-blur",
  "dm-submit", "dm-select", "dm-close", "dm-open", "dm-toggle",
];

/**
 * WebComponentHook - Universal LiveView ↔ Custom Element bridge
 *
 * This hook enables seamless communication between Phoenix LiveView
 * and duskmoon-elements custom elements (el-dm-*).
 *
 * ## Event Bridging Patterns
 *
 * ### Forward custom element events to LiveView:
 * Use `duskmoon-send-{event}` attribute:
 * ```html
 * <el-dm-button duskmoon-send-click="handle_click">Click me</el-dm-button>
 * ```
 *
 * ### Receive LiveView events in custom element:
 * Use `duskmoon-receive-{event}` attribute:
 * ```html
 * <el-dm-input duskmoon-receive-reset="reset">Input</el-dm-input>
 * ```
 *
 * ### Automatic dm-* event forwarding:
 * Events prefixed with `dm-` (dm-click, dm-change, dm-input, etc.)
 * are automatically forwarded to LiveView when corresponding
 * `phx-{event}` attribute exists.
 *
 * ## Usage in Phoenix templates:
 * ```heex
 * <el-dm-button
 *   phx-hook="WebComponentHook"
 *   phx-click="button_clicked"
 *   variant="primary"
 * >
 *   Click me
 * </el-dm-button>
 * ```
 */
export const WebComponentHook = {
  mounted() {
    this._sendListeners = [];
    this._setupEventBridging();
    this._setupAutomaticForwarding();
  },

  updated() {
    // Re-check attributes on update in case they changed
    this._setupAutomaticForwarding();
  },

  destroyed() {
    // Remove duskmoon-send-* event listeners
    if (this._sendListeners) {
      this._sendListeners.forEach(({ event, listener }) => {
        this.el.removeEventListener(event, listener);
      });
      this._sendListeners = null;
    }
    // Remove dm-* automatic forwarding listeners
    DM_EVENTS.forEach((dmEvent) => {
      const listenerKey = `_dm_listener_${dmEvent}`;
      if (this[listenerKey]) {
        this.el.removeEventListener(dmEvent, this[listenerKey]);
        this[listenerKey] = null;
      }
    });
  },

  /**
   * Setup explicit event bridging via duskmoon-send-* and duskmoon-receive-* attributes
   */
  _setupEventBridging() {
    const attrs = this.el.attributes;
    const phxTarget = this.el.getAttribute("phx-target");

    // Helper to push events with optional target
    const pushEvent = (event, payload, callback) => {
      if (phxTarget) {
        this.pushEventTo(phxTarget, event, payload, callback);
      } else {
        this.pushEvent(event, payload, callback);
      }
    };

    for (let i = 0; i < attrs.length; i++) {
      const attr = attrs[i];

      // Handle duskmoon-send-{event}="{phxEvent};{optionalCallback}"
      if (/^duskmoon-send-/.test(attr.name)) {
        const eventName = attr.name.replace(/^duskmoon-send-/, "");
        const [phxEvent, callbackName] = attr.value.split(";");

        const listener = ({ detail }) => {
          pushEvent(phxEvent, detail || {}, (response) => {
            if (callbackName && typeof this[callbackName] === "function") {
              this[callbackName](response, detail, eventName);
            }
          });
        };
        this.el.addEventListener(eventName, listener);
        this._sendListeners.push({ event: eventName, listener });
      }

      // Handle duskmoon-receive-{event}="{handlerMethodOrEmpty}"
      if (/^duskmoon-receive-/.test(attr.name)) {
        const eventName = attr.name.replace(/^duskmoon-receive-/, "");
        const handler = attr.value;

        this.handleEvent(eventName, (payload) => {
          if (handler && typeof this.el[handler] === "function") {
            this.el[handler](payload);
          } else {
            // Dispatch as custom event on the element
            this.el.dispatchEvent(
              new CustomEvent(eventName, {
                detail: payload,
                bubbles: true,
                composed: true,
              })
            );
          }
        });
      }

      // Handle duskmoon-receive="{phxEvent};{callbackName}"
      if (attr.name === "duskmoon-receive") {
        const [phxEvent, callbackName] = attr.value.split(";");
        this.handleEvent(phxEvent, (payload) => {
          if (typeof this.el[callbackName] === "function") {
            this.el[callbackName](payload);
          }
        });
      }
    }
  },

  /**
   * Setup automatic forwarding for dm-* events to phx-* handlers
   *
   * This enables the common pattern of:
   * <el-dm-button phx-hook="WebComponentHook" phx-click="handle_click">
   *
   * When el-dm-button emits 'dm-click', it automatically calls the phx-click handler
   */
  _setupAutomaticForwarding() {
    const phxTarget = this.el.getAttribute("phx-target");

    DM_EVENTS.forEach((dmEvent) => {
      // Map dm-click -> phx-click, dm-change -> phx-change, etc.
      const phxAttr = "phx-" + dmEvent.replace("dm-", "");
      const phxEvent = this.el.getAttribute(phxAttr);

      if (phxEvent) {
        // Remove existing listener to avoid duplicates on update
        const listenerKey = `_dm_listener_${dmEvent}`;
        if (this[listenerKey]) {
          this.el.removeEventListener(dmEvent, this[listenerKey]);
        }

        // Create and store the listener
        this[listenerKey] = (e) => {
          const detail = e.detail || {};

          // Include common form data if available
          const payload = {
            ...detail,
            value: this.el.value,
            name: this.el.name,
            checked: this.el.checked,
          };

          if (phxTarget) {
            this.pushEventTo(phxTarget, phxEvent, payload);
          } else {
            this.pushEvent(phxEvent, payload);
          }
        };

        this.el.addEventListener(dmEvent, this[listenerKey]);
      }
    });
  },
};

/**
 * FormElementHook - Specialized hook for form custom elements
 *
 * Extends WebComponentHook with form-specific behavior:
 * - Integrates with Phoenix.HTML.Form
 * - Handles phx-feedback-for error display
 * - Manages form field state
 */
export const FormElementHook = {
  ...WebComponentHook,

  mounted() {
    // Call parent mounted
    WebComponentHook.mounted.call(this);

    // Setup form integration
    this._setupFormIntegration();
  },

  _setupFormIntegration() {
    const name = this.el.getAttribute("name");
    const feedbackFor = this.el.getAttribute("phx-feedback-for") || name;

    if (feedbackFor) {
      // Watch for phx-no-feedback class changes to show/hide errors
      this._setupFeedbackObserver(feedbackFor);
    }
  },

  destroyed() {
    WebComponentHook.destroyed.call(this);
    if (this._feedbackObserver) {
      this._feedbackObserver.disconnect();
      this._feedbackObserver = null;
    }
  },

  _setupFeedbackObserver(feedbackFor) {
    // Find the form wrapper that Phoenix LiveView manages
    const form = this.el.closest("form");
    if (!form) return;

    // Observe class changes on form for feedback state
    this._feedbackObserver = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.attributeName === "class") {
          const hasNoFeedback = form.classList.contains("phx-no-feedback");
          // Dispatch event to custom element to show/hide errors
          this.el.dispatchEvent(
            new CustomEvent("dm-feedback-change", {
              detail: { showFeedback: !hasNoFeedback, field: feedbackFor },
            })
          );
        }
      });
    });

    this._feedbackObserver.observe(form, { attributes: true, attributeFilter: ["class"] });
  },
};

// Export to window for non-module usage
if (typeof window !== "undefined") {
  window.__WebComponentHook__ = WebComponentHook;
  window.__FormElementHook__ = FormElementHook;
}
