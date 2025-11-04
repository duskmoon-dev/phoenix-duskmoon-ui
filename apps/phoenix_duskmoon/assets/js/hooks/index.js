/**
 * Phoenix Duskmoon UI Hooks
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
 */

export { ThemeSwitcher } from './theme_switcher.js';
export { Spotlight } from './spotlight.js';
export { PageHeader } from './page_header.js';
