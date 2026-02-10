# Core Package API

`@duskmoon-dev/el-core` — foundation for all custom elements. Zero runtime dependencies.

## Exports

| Category | Exports |
|----------|---------|
| **Base class** | `BaseElement`, `PropertyDefinition`, `PropertyDefinitions` |
| **Styles** | `css`, `combineStyles`, `cssVars`, `defaultTheme`, `resetStyles`, `lightThemeColors` |
| **Animations** | `animationStyles`, `animation`, `transition`, `durations`, `easings` |
| **Themes** | `sunshineTheme`, `moonlightTheme`, `oceanTheme`, `forestTheme`, `roseTheme`, `themes`, `applyTheme` |
| **Mixins** | `FocusableMixin`, `FormMixin`, `EventListenerMixin`, `SlotObserverMixin` |
| **Validation** | `validate`, `validateAsync`, `validators` |
| **Performance** | `debounce`, `throttle`, `scheduleIdle` |
| **Types** | `Size`, `Variant`, `ValidationState`, `BaseElementProps`, `SizableProps`, `VariantProps`, `FormElementProps`, `ValidatableProps`, `ValueChangeEventDetail`, `AttributeConverter`, `CSSValue`, `AnimationDuration`, `AnimationEasing`, `ThemeName`, `ValidationResult`, `Validator` |

## BaseElement API

| Method | Description |
|--------|-------------|
| `attachStyles(sheet)` | Add `CSSStyleSheet`(s) to shadow DOM via `adoptedStyleSheets` |
| `render(): string` | Override to return HTML string for shadow DOM content |
| `update()` | Called on property changes — default calls `render()` |
| `emit<T>(name, detail?)` | Dispatch composed, bubbling `CustomEvent` |
| `query<T>(selector)` | `shadowRoot.querySelector()` shorthand |
| `queryAll<T>(selector)` | `shadowRoot.querySelectorAll()` shorthand |
| `connectedCallback()` | Element added to DOM — always call `super.connectedCallback()` |
| `disconnectedCallback()` | Element removed from DOM — cleanup listeners |

## Mixins

| Mixin | Adds |
|-------|------|
| `FocusableMixin` | `focused` property, tabindex management, focus/blur tracking |
| `FormMixin` | `name`, `value`, `disabled`, `required` properties, `form` getter |
| `EventListenerMixin` | `addListener()` with auto-cleanup on disconnect |
| `SlotObserverMixin` | `observeSlot()` for tracking slot content changes |

## Style Utilities

```typescript
import { css, combineStyles, cssVars } from '@duskmoon-dev/el-core';

const styles = css`:host { display: block; }`;
const combined = combineStyles(resetStyles, defaultTheme, styles);
const vars = cssVars({ '--my-color': 'red' });
```

## Theme Presets

Five built-in themes using oklch color system: `sunshine`, `moonlight`, `ocean`, `forest`, `rose`.

```typescript
import { applyTheme } from '@duskmoon-dev/el-core';
applyTheme(element, 'moonlight');
applyTheme(element, '--color-primary: red;'); // custom CSS string
```

## CSS Custom Properties

### Colors
- `--color-primary`, `--color-on-primary`
- `--color-secondary`, `--color-on-secondary`
- `--color-tertiary`, `--color-on-tertiary`
- `--color-success`, `--color-on-success`
- `--color-warning`, `--color-on-warning`
- `--color-error`, `--color-on-error`
- `--color-info`, `--color-on-info`

### Surfaces
- `--color-surface`, `--color-on-surface`
- `--color-surface-dim`, `--color-surface-bright`
- `--color-surface-container-lowest` / `-low` / (default) / `-high` / `-highest`
- `--color-on-surface-variant`
- `--color-outline`, `--color-outline-variant`

### Layout
- `--spacing-xs` through `--spacing-xl`
- `--radius-sm` through `--radius-full`
- `--shadow-sm`, `--shadow-md`, `--shadow-lg`

### Typography
- `--font-family`, `--font-size-*`, `--font-weight-*`

**Important:** Use `--color-surface-container` NOT `--color-surface-variant` (doesn't exist in theme).

## Validation

```typescript
import { validate, validators } from '@duskmoon-dev/el-core';

const result = validate('hello@example.com', [
  validators.required('Email is required'),
  validators.email('Must be a valid email'),
]);
// → { state: 'valid', message: undefined }
```

Available: `required`, `minLength`, `maxLength`, `pattern`, `email`, `range`, `custom`.

## Performance Utilities

```typescript
import { debounce, throttle, scheduleIdle } from '@duskmoon-dev/el-core';

const search = debounce((q: string) => { /* ... */ }, 300);
const onScroll = throttle(() => { /* ... */ }, 100);
const cancel = scheduleIdle(() => { /* cleanup */ }, { timeout: 1000 });
```
