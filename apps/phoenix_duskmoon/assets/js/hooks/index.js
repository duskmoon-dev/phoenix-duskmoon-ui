/**
 * Phoenix Duskmoon UI v9 Hooks
 *
 * Import and export all LiveView hooks required by Phoenix Duskmoon UI components.
 *
 * ## Usage in your Phoenix app:
 *
 * ```javascript
 * import {LiveSocket} from "phoenix_live_view"
 * import * as DuskmoonHooks from "phoenix_duskmoon/hooks"
 *
 * let liveSocket = new LiveSocket("/live", Socket, {
 *   params: {_csrf_token: csrfToken},
 *   hooks: DuskmoonHooks
 * })
 * ```
 *
 * ## Available Hooks:
 *
 * - WebComponentHook: Universal LiveView ↔ Custom Element bridge
 * - FormElementHook: Specialized hook for form custom elements
 * - ThemeSwitcher: Theme toggle with localStorage persistence
 * - Spotlight: Keyboard shortcut (Cmd/Ctrl+K) for spotlight search
 * - PageHeader: Intersection observer for scroll-based effects
 */

// Core hooks for custom element integration
export { WebComponentHook, FormElementHook } from '../phoenix_duskmoon.js';

// Component-specific hooks
export { ThemeSwitcher } from './theme_switcher.js';
export { Spotlight } from './spotlight.js';
export { PageHeader } from './page_header.js';
