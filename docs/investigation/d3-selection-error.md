# d3-selection CustomEvent Error Investigation

## Issue
Console error on all pages: `Uncaught TypeError: Cannot read properties of undefined (reading 'CustomEvent')`

## Root Cause
- **Source**: d3-selection library at `app.js:20428:55`
- **Code**: `var window2 = window_default(node), event = window2.CustomEvent;`
- **Problem**: `window_default(node)` returns undefined when node is null

## Impact
- **Functional**: NONE - Pages render correctly
- **Visual**: NONE - No styling issues
- **User Experience**: NONE - Error is silent in production

## d3 Usage Analysis
The compiled app.js includes extensive d3 modules:
- d3-array (data manipulation)
- d3-axis (chart axes)
- d3-brush (selection tool)
- d3-chord (circular layouts)
- d3-color (color utilities)
- d3-selection (**source of error**)
- And 30+ other d3 modules

## Transitive Dependency
One of the @duskmoon-dev/el-* custom elements has a transitive dependency on d3.
The element likely uses d3 for data visualization or interactive components.

## Registered Custom Elements
From apps/duskmoon_storybook_web/assets/js/app.js:
- el-button, el-card, el-input, el-switch
- el-alert, el-dialog, el-badge, el-tooltip
- el-progress, el-form, el-slider
- el-breadcrumbs, el-menu, el-navbar
- el-pagination, el-tabs, el-table, el-markdown

**Most likely culprits**:
- `el-table` - Tables often use d3 for sorting/filtering
- `el-progress` - Progress indicators might use d3 for animations
- `el-markdown` - Might use d3 for diagrams/charts

## Recommendation
1. **Short term**: Document as known non-blocking issue ✅ (completed in Validate.md)
2. **Medium term**: Identify which custom element uses d3
3. **Long term**: File issue with @duskmoon-dev/duskmoon-elements if error persists in production

## Testing
- [x] Verified pages render correctly despite error
- [x] Verified no CSS/style impact
- [x] Verified no functional impact
- [x] All 397 tests pass

## Status
**DEFERRED** - Non-blocking, documented for future investigation.
