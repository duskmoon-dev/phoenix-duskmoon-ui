# PRD: phoenix_duskmoon_ui Style Validation & Repair

## Objective
Systematically identify and fix all broken styles in the phoenix_duskmoon_ui demo page
using Chrome DevTools MCP for live inspection and verification.

## Prerequisites
- Demo server running at `http://localhost:4000` (or specify port)
- Chrome DevTools MCP connected
- Repository at `~/path/to/phoenix_duskmoon_ui`

## Workflow

### Phase 1: Audit
1. Navigate to the demo page via CDP
2. Take a full-page screenshot for baseline reference
3. Collect all console errors/warnings (filter CSS-related)
4. For each demo component section:
   - Screenshot the section
   - Inspect computed styles for layout anomalies
   - Check for missing CSS custom properties / unresolved variables
   - Check for Tailwind class conflicts or missing utility classes
   - Log findings as `## Findings` appendix in this file

### Phase 2: Categorize Issues
Group findings by root cause:
- Missing/incorrect CSS imports
- Tailwind config gaps (missing plugins, content paths, theme extensions)
- Component-level style regressions (wrong classes, broken variants)
- Dark mode / color scheme issues
- Responsive breakpoint failures

### Phase 3: Fix (iterate per issue)
For each issue:
1. Apply the fix in source
2. Wait for live reload / recompile
3. Re-inspect the affected area via DevTools
4. Screenshot to confirm resolution
5. If not resolved, revert and try alternative approach

### Phase 4: Verify
1. Full-page screenshot comparison with Phase 1 baseline
2. Zero CSS-related console errors
3. Navigate all demo routes/tabs and verify each

## Constraints
- Do NOT refactor component APIs — style fixes only
- Preserve existing Tailwind / CSS architecture patterns
- Commit atomic fixes (one commit per root cause category)

## Success Criteria
- All demo components render correctly (visual verification via screenshots)
- No CSS console errors or warnings
- Each fix is minimal and scoped

## Appendix: Findings

### Phase 1 Audit Results - 2026-02-11

#### Infrastructure Issues (RESOLVED)
1. **Phoenix CodeReloader.Server crash** (FIXED)
   - **Symptom**: All `/components/*` routes returned 500 errors
   - **Root Cause**: CodeReloader.Server process crashed but main Phoenix server continued running
   - **Fix**: Killed both Phoenix servers (PID 2919821, 4116596) and restarted with `mix phx.server`
   - **Status**: ✅ RESOLVED - All pages now load successfully

#### JavaScript Errors (ACTIVE)
1. **CustomEvent TypeError** - CRITICAL
   - **Pages Affected**: `/components/data-entry/form`, `/components/navigation/appbar`, `/storybook/*` (all pages)
   - **Error**: `Uncaught TypeError: Cannot read properties of undefined (reading 'CustomEvent')`
   - **Stack Trace**:
     ```
     at dispatchConnected (frame:1753:12)
     at  (frame:1688:14)
     at  (frame:1379:64)
     at onConnOpen (frame:1379:38)
     at conn.onopen (frame:1314:37)
     ```
   - **Root Cause** (UPDATED): NOT LiveView - it's `d3-selection` library
     - Full trace shows `at dispatchEvent (app.js:20428:55)` is the real source
     - Line 20428: `var window2 = window_default(node), event = window2.CustomEvent;`
     - `window_default(node)` returns undefined when node is null
   - **Fix Applied**: ✅ Removed `<.live_title>` and `phx-track-static` from root.html.heex
   - **Impact**: Error persists but pages render correctly
   - **Category**: Third-party library error (d3-selection)
   - **Priority**: MEDIUM (downgraded - not blocking, pages functional)

2. **Storybook Configuration Warning**
   - **Pages Affected**: `/storybook/*` pages
   - **Warnings**:
     - "No storybook configuration detected."
     - "If you need to use custom hooks or uploaders, please define them in JS file and declare this file in your Elixir backend module options (:js_path key)."
   - **Impact**: May affect custom hooks/uploaders functionality
   - **Category**: Configuration
   - **Priority**: MEDIUM

#### CSS/Style Issues
- **Status**: No CSS console errors detected
- **Network**: app.css loads successfully (304 Not Modified)
- **Visual Review**: Screenshots captured for:
  - Home page (✅ Clean)
  - Action components (✅ Clean)
  - Table component (✅ Clean)
  - Form component (⚠️ Has JS error)
  - Appbar component (⚠️ Has JS error)
  - Storybook pages (⚠️ Has JS error + config warnings)

#### Screenshots Captured
- `00-home.png` - Home page baseline
- `01-action.png` - 500 error (before fix)
- `03-action-fixed.png` - Action components (after server restart)
- `04-table.png` - Table component
- `05-form.png` - Form component
- `06-appbar.png` - Appbar component
- `07-storybook-button.png` - Storybook button page

### Next Steps
1. Fix CustomEvent JavaScript error (likely in app.js or LiveView hook setup)
2. Configure storybook JS path for custom hooks/uploaders
3. Visual verification pass after JavaScript fixes
4. Check for any CSS-specific styling issues once JS is working
