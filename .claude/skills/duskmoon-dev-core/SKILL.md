---
name: duskmoon-dev-core
description: When using npm package `@duskmoon-dev/core`, this skill shows how to install, configure, and use the CSS component library
---

# @duskmoon-dev/core Skill

## Overview

`@duskmoon-dev/core` is a CSS-only component library for Tailwind CSS v4 with Material Design 3's extended color system.

## Installation

```bash
# Bun
bun add @duskmoon-dev/core tailwindcss@^4.0.0

# npm
npm install @duskmoon-dev/core tailwindcss@^4.0.0

# pnpm
pnpm add @duskmoon-dev/core tailwindcss@^4.0.0
```

## Setup

### CSS Import

```css
@import "tailwindcss";
@import "@duskmoon-dev/core";
```

### Theme Configuration

Apply theme via `data-theme` attribute on HTML element:

```html
<html data-theme="sunshine">  <!-- Light theme -->
<html data-theme="moonlight"> <!-- Dark theme -->
```

## Available Components

### Actions
- `btn` - Buttons with variants: `btn-primary`, `btn-secondary`, `btn-tertiary`, `btn-outline`, `btn-ghost`, `btn-text`, `btn-loading`

### Data Entry
- `input` - Text inputs: `input-primary`, `input-secondary`, `input-error`
- `textarea` - Multi-line text: `textarea-primary`, `textarea-resize-none`, `textarea-resize-vertical`
- `select` - Dropdown selection: `select-primary`, `select-filled`, `select-outlined`
- `cascader` - Hierarchical selection: `cascader`, `cascader-panel`, `cascader-menu`
- `checkbox` - Checkboxes: `checkbox-primary`, `checkbox-indeterminate`, `checkbox-group`
- `radio` - Radio buttons: `radio-primary`, `radio-group`, `radio-group-horizontal`
- `switch` - Toggle switches: `switch-primary`, `switch-secondary`
- `slider` - Range sliders
- `segment-control` - Segmented buttons: `segment-control`, `segment-control-item`
- `autocomplete` - Search with suggestions
- `datepicker` - Calendar: date, datetime, date range, datetime range pickers
- `time-input` - Time selection: `time-input`, `time-input-picker`
- `file-upload` - Drag-and-drop file uploader
- `rating` - Star/heart ratings
- `otp-input` - OTP verification: `otp-input`, `otp-input-field`
- `pin-input` - PIN entry: `pin-input`, `pin-input-masked`
- `multi-select` - Multiple selection: `multi-select`, `multi-select-tag`
- `tree-select` - Hierarchical dropdown: `tree-select`, `tree-select-node`
- `form-group` - Form layout: `form-group`, `form-label`, `helper-text`, `fieldset`

### Data Display
- `card` - Content containers: `card-body`, `card-title`
- `badge` - Status indicators: `badge-primary`, `badge-dot`
- `avatar` - User images: `avatar-lg`, `avatar-status-online`
- `chip` - Tags/filters: `chip-primary`, `chip-removable`
- `table` - Data tables: `table-hover`, `table-striped`
- `list` - Vertical lists: `list-item`, `list-item-interactive`
- `timeline` - Chronological events

### Feedback
- `alert` - Messages: `alert-success`, `alert-error`, `alert-warning`, `alert-info`
- `dialog` - Modal dialogs: `dialog-backdrop`, `dialog-md`
- `modal` - Full overlays
- `toast` - Notifications: `toast-success`, `toast-show`
- `snackbar` - Brief messages
- `progress` - Loading: `progress-primary`, `progress-indeterminate`
- `skeleton` - Placeholders: `skeleton-text`, `skeleton-circle`
- `tooltip` - Hover info: `tooltip-top`, `tooltip-bottom`

### Navigation
- `navbar` - Top navigation: `navbar-surface-container-high`, `navbar-item`
- `tabs` - Tab navigation: `tab`, `tab-active`
- `drawer` - Side panels: `drawer-left`, `drawer-open`
- `bottom-nav` - Mobile navigation: `bottom-nav-item`
- `stepper` - Multi-step: `stepper-step-active`, `stepper-step-completed`

### Layout
- `divider` - Separators: `divider-dashed`, `divider-vertical`
- `appbar` - Action bars: `appbar-top`, `appbar-bottom`
- `grid-cols-auto-fill-*` - Responsive grid with auto-fill: `grid-cols-auto-fill-48`, `grid-cols-auto-fill-64`
- `grid-cols-auto-fit-*` - Responsive grid with auto-fit: `grid-cols-auto-fit-48`, `grid-cols-auto-fit-64`

### Utilities
- `sr-only` - Screen reader only (visually hidden but accessible)
- `not-sr-only` - Undo sr-only for focus states

### Surfaces
- `accordion` - Expandable panels: `accordion-item-open`
- `bottomsheet` - Mobile panels: `bottom-sheet-show`
- `popover` - Contextual overlays: `popover-top`, `popover-show`
- `collapse` - Collapsible content

## Usage Examples

### Buttons

```html
<button class="btn btn-primary">Primary</button>
<button class="btn btn-secondary btn-outline">Outlined</button>
<button class="btn btn-tertiary btn-ghost">Ghost</button>
<button class="btn btn-primary btn-loading">Loading...</button>
```

### Cards

```html
<div class="card">
  <div class="card-body">
    <h2 class="card-title">Title</h2>
    <p>Content</p>
  </div>
</div>
```

### Forms

```html
<input type="text" class="input" placeholder="Default" />
<input type="text" class="input input-primary" placeholder="Primary" />
<input type="text" class="input input-error" placeholder="Error" />
```

### Alerts

```html
<div class="alert alert-success">Success message</div>
<div class="alert alert-error">Error message</div>
<div class="alert alert-warning">Warning message</div>
<div class="alert alert-info">Info message</div>
```

### Navigation

```html
<nav class="navbar navbar-surface-container-high">
  <div class="navbar-start">
    <a class="navbar-brand">Logo</a>
  </div>
  <div class="navbar-center">
    <a class="navbar-item navbar-item-active">Home</a>
    <a class="navbar-item">About</a>
  </div>
</nav>
```

### Tabs

```html
<div class="tabs">
  <button class="tab tab-active">Tab 1</button>
  <button class="tab">Tab 2</button>
</div>
```

### Dialog

```html
<div class="dialog-backdrop dialog-backdrop-show">
  <div class="dialog dialog-md">
    <div class="dialog-header">
      <h2 class="dialog-title">Title</h2>
    </div>
    <div class="dialog-body">Content</div>
    <div class="dialog-actions">
      <button class="btn btn-text">Cancel</button>
      <button class="btn btn-filled">Confirm</button>
    </div>
  </div>
</div>
```

### Responsive Grid

```html
<!-- Auto-fill: Fixed column size, empty space on right -->
<div class="grid grid-cols-auto-fill-48 gap-4">
  <div class="card">Item 1</div>
  <div class="card">Item 2</div>
  <div class="card">Item 3</div>
</div>

<!-- Auto-fit: Columns stretch to fill container -->
<div class="grid grid-cols-auto-fit-64 gap-4">
  <div class="card">Item 1</div>
  <div class="card">Item 2</div>
</div>
```

## Color System

### Color Utilities

```html
<!-- Backgrounds -->
<div class="bg-primary">Primary</div>
<div class="bg-secondary">Secondary</div>
<div class="bg-tertiary">Tertiary</div>
<div class="bg-surface-container">Surface</div>

<!-- Text -->
<p class="text-primary">Primary</p>
<p class="text-on-surface">On surface</p>
<p class="text-on-surface-variant">Muted</p>

<!-- Semantic -->
<div class="bg-success text-success-content">Success</div>
<div class="bg-error text-error-content">Error</div>
```

### CSS Variables

```css
.custom {
  background-color: var(--color-primary);
  color: var(--color-primary-content);
  border-color: var(--color-outline);
}
```

## Theme Switching

```javascript
// Switch to dark theme
document.documentElement.dataset.theme = 'moonlight';

// Switch to light theme
document.documentElement.dataset.theme = 'sunshine';
```

## Importing Component Styles

### Full Library Import

Import all components and themes at once:

```css
/* In your CSS file */
@import "tailwindcss";
@import "@duskmoon-dev/core";
```

### Individual Component CSS Import

Import only the CSS you need for smaller bundle sizes:

```css
/* CSS imports */
@import "@duskmoon-dev/core/components/button";
@import "@duskmoon-dev/core/components/card";
@import "@duskmoon-dev/core/components/input";
@import "@duskmoon-dev/core/components/alert";
```

### JavaScript/TypeScript Import

```javascript
// Import component styles in JS/TS
import '@duskmoon-dev/core/components/button';
import '@duskmoon-dev/core/components/card';
import '@duskmoon-dev/core/components/input';
```

### Theme-Only Import

```css
/* Import specific themes */
@import "@duskmoon-dev/core/themes/sunshine";
@import "@duskmoon-dev/core/themes/moonlight";
```

### Available Component Exports

All components available for individual import:

| Import Path | Component |
|-------------|-----------|
| `@duskmoon-dev/core/components/accordion` | Accordion |
| `@duskmoon-dev/core/components/alert` | Alert |
| `@duskmoon-dev/core/components/appbar` | App Bar |
| `@duskmoon-dev/core/components/autocomplete` | Autocomplete |
| `@duskmoon-dev/core/components/avatar` | Avatar |
| `@duskmoon-dev/core/components/badge` | Badge |
| `@duskmoon-dev/core/components/bottom-navigation` | Bottom Navigation |
| `@duskmoon-dev/core/components/bottomsheet` | Bottom Sheet |
| `@duskmoon-dev/core/components/button` | Button |
| `@duskmoon-dev/core/components/card` | Card |
| `@duskmoon-dev/core/components/cascader` | Cascader |
| `@duskmoon-dev/core/components/checkbox` | Checkbox |
| `@duskmoon-dev/core/components/chip` | Chip |
| `@duskmoon-dev/core/components/collapse` | Collapse |
| `@duskmoon-dev/core/components/datepicker` | Date Picker |
| `@duskmoon-dev/core/components/dialog` | Dialog |
| `@duskmoon-dev/core/components/divider` | Divider |
| `@duskmoon-dev/core/components/drawer` | Drawer |
| `@duskmoon-dev/core/components/file-upload` | File Upload |
| `@duskmoon-dev/core/components/form` | Form |
| `@duskmoon-dev/core/components/form-group` | Form Group |
| `@duskmoon-dev/core/components/input` | Input |
| `@duskmoon-dev/core/components/list` | List |
| `@duskmoon-dev/core/components/markdown-body` | Markdown Body |
| `@duskmoon-dev/core/components/modal` | Modal |
| `@duskmoon-dev/core/components/multi-select` | Multi-Select |
| `@duskmoon-dev/core/components/navigation` | Navigation (Navbar/Tabs/Menu) |
| `@duskmoon-dev/core/components/otp-input` | OTP Input |
| `@duskmoon-dev/core/components/pin-input` | PIN Input |
| `@duskmoon-dev/core/components/popover` | Popover |
| `@duskmoon-dev/core/components/progress` | Progress |
| `@duskmoon-dev/core/components/radio` | Radio |
| `@duskmoon-dev/core/components/rating` | Rating |
| `@duskmoon-dev/core/components/segment-control` | Segment Control |
| `@duskmoon-dev/core/components/select` | Select |
| `@duskmoon-dev/core/components/skeleton` | Skeleton |
| `@duskmoon-dev/core/components/slider` | Slider |
| `@duskmoon-dev/core/components/snackbar` | Snackbar |
| `@duskmoon-dev/core/components/stepper` | Stepper |
| `@duskmoon-dev/core/components/switch` | Switch |
| `@duskmoon-dev/core/components/table` | Table |
| `@duskmoon-dev/core/components/textarea` | Textarea |
| `@duskmoon-dev/core/components/time-input` | Time Input |
| `@duskmoon-dev/core/components/timeline` | Timeline |
| `@duskmoon-dev/core/components/toast` | Toast |
| `@duskmoon-dev/core/components/tooltip` | Tooltip |
| `@duskmoon-dev/core/components/tree-select` | Tree Select |

### Usage in Web Components / Custom Elements

Each component exports a named `css` export containing the CSS string:

```javascript
// Import the css named export
import { css as buttonCSS } from '@duskmoon-dev/core/components/button';
import { css as cardCSS } from '@duskmoon-dev/core/components/card';
import { css as inputCSS } from '@duskmoon-dev/core/components/input';
```

Example usage in a custom element:

```javascript
import { css as buttonCSS } from '@duskmoon-dev/core/components/button';

// Strip @layer wrapper for Shadow DOM compatibility
const coreStyles = buttonCSS.replace(/@layer\s+components\s*\{/, '').replace(/\}\s*$/, '');

class MyButton extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' });

    // Add styles to shadow DOM
    const style = document.createElement('style');
    style.textContent = coreStyles;
    this.shadowRoot.appendChild(style);
  }
}
```

Note: The CSS is wrapped in `@layer components { }` for Tailwind CSS cascade layers. When using in Shadow DOM, strip the `@layer` wrapper as shown above.
