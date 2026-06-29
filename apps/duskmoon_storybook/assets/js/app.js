import "phoenix_html";
import * as DuskmoonHooks from "phoenix_duskmoon/hooks";

// Make Duskmoon hooks available in PhoenixStorybook LiveView iframes
window.storybook = { Hooks: DuskmoonHooks };

let codeEngineShadowStyleWorkaroundInstalled = false;
let codeEngineLayoutWorkaroundInstalled = false;
let codeEngineLayoutWorkaroundFrame = undefined;

const codeEngineLayoutWorkaroundStyleId = "duskmoon-code-engine-layout-workaround";

function getPropertyDescriptor(object, property) {
  for (let current = object; current; current = Object.getPrototypeOf(current)) {
    const descriptor = Object.getOwnPropertyDescriptor(current, property);
    if (descriptor) return descriptor;
  }

  return undefined;
}

function installCodeEngineShadowStyleWorkaround() {
  if (codeEngineShadowStyleWorkaroundInstalled || typeof ShadowRoot === "undefined") return;

  const descriptor = getPropertyDescriptor(ShadowRoot.prototype, "adoptedStyleSheets");
  if (!descriptor || !descriptor.configurable || !descriptor.get || !descriptor.set) return;

  codeEngineShadowStyleWorkaroundInstalled = true;
  Object.defineProperty(ShadowRoot.prototype, "adoptedStyleSheets", {
    configurable: true,
    get() {
      // WORKAROUND(upstream): duskmoon-dev/code-engine#9
      // CodeMirror's vendored StyleSet reuses adopted sheets with a constructor bug.
      // Keep adoptedStyleSheets available to BaseElement so component styles still apply.
      if (this.host?.localName === "el-dm-code-engine") {
        const stack = new Error().stack || "";
        if (stack.includes("StyleSet") || stack.includes("StyleModule.mount")) {
          return undefined;
        }
      }

      return descriptor.get.call(this);
    },
    set(value) {
      descriptor.set.call(this, value);
    }
  });
}

function applyCodeEngineLayoutWorkaround(host) {
  const root = host.shadowRoot;
  if (!root || root.getElementById(codeEngineLayoutWorkaroundStyleId)) return;

  const style = document.createElement("style");
  style.id = codeEngineLayoutWorkaroundStyleId;
  style.textContent = `
    /* WORKAROUND(upstream): duskmoon-dev/code-engine#10 */
    .cm-host {
      display: flex;
      flex-direction: column;
      flex: 1 1 auto;
      min-height: 0;
    }

    .cm-host .cm-editor {
      flex: 1 1 auto;
      min-height: 0;
    }
  `;
  root.appendChild(style);
}

function patchCodeEngineLayout() {
  document.querySelectorAll("el-dm-code-engine").forEach(applyCodeEngineLayoutWorkaround);
}

function scheduleCodeEngineLayoutPatch() {
  if (codeEngineLayoutWorkaroundFrame !== undefined) return;

  codeEngineLayoutWorkaroundFrame = requestAnimationFrame(() => {
    codeEngineLayoutWorkaroundFrame = undefined;
    patchCodeEngineLayout();
  });
}

function installCodeEngineLayoutWorkaround() {
  if (codeEngineLayoutWorkaroundInstalled) return;

  codeEngineLayoutWorkaroundInstalled = true;
  scheduleCodeEngineLayoutPatch();

  new MutationObserver(scheduleCodeEngineLayoutPatch)
    .observe(document.documentElement, { childList: true, subtree: true });
}

function withCodeEngineOneDarkThemeWorkaround(load) {
  const objectValues = Object.values;

  const patchedObjectValues = function patchedObjectValues(value) {
    const values = objectValues(value);

    // WORKAROUND(upstream): duskmoon-dev/duskmoon-elements#65
    // el-code-engine picks the first non-string namespace export; one-dark exports
    // a color map before the actual extension array.
    if (value?.color && Array.isArray(value?.oneDark) && values.includes(value.color)) {
      return [value.oneDark, ...values.filter((item) => item !== value.oneDark)];
    }

    return values;
  };

  Object.values = patchedObjectValues;

  return Promise.resolve()
    .then(load)
    .finally(() => {
      if (Object.values === patchedObjectValues) {
        Object.values = objectValues;
      }
    });
}

function withCodeEngineWorkarounds(load) {
  installCodeEngineShadowStyleWorkaround();

  return withCodeEngineOneDarkThemeWorkaround(load).then((result) => {
    installCodeEngineLayoutWorkaround();
    return result;
  });
}

function registerCodeEngineElement() {
  return import("@duskmoon-dev/el-code-engine/register");
}

registerCodeEngineElement.duskmoonBeforeVendorImport = withCodeEngineWorkarounds;

const duskmoonElementRegistrars = {
  "el-dm-accordion": () => import("@duskmoon-dev/el-accordion/register"),
  "el-dm-art-atom": () => import("@duskmoon-dev/el-art-atom/register"),
  "el-dm-art-cat-stargazer": () => import("@duskmoon-dev/el-art-cat-stargazer/register"),
  "el-dm-art-circular-gallery": () => import("@duskmoon-dev/el-art-circular-gallery/register"),
  "el-dm-art-color-spin": () => import("@duskmoon-dev/el-art-color-spin/register"),
  "el-dm-art-csswitch": () => import("@duskmoon-dev/el-art-csswitch/register"),
  "el-dm-art-eclipse": () => import("@duskmoon-dev/el-art-eclipse/register"),
  "el-dm-art-flower-animation": () => import("@duskmoon-dev/el-art-flower-animation/register"),
  "el-dm-art-gemini-input": () => import("@duskmoon-dev/el-art-gemini-input/register"),
  "el-dm-art-moon": () => import("@duskmoon-dev/el-art-moon/register"),
  "el-dm-art-mountain": () => import("@duskmoon-dev/el-art-mountain/register"),
  "el-dm-art-plasma-ball": () => import("@duskmoon-dev/el-art-plasma-ball/register"),
  "el-dm-art-snow": () => import("@duskmoon-dev/el-art-snow/register"),
  "el-dm-art-snowball-preloader": () => import("@duskmoon-dev/el-art-snowball-preloader/register"),
  "el-dm-art-sun": () => import("@duskmoon-dev/el-art-sun/register"),
  "el-dm-art-synthwave-starfield": () => import("@duskmoon-dev/el-art-synthwave-starfield/register"),
  "el-dm-alert": () => import("@duskmoon-dev/el-alert/register"),
  "el-dm-autocomplete": () => import("@duskmoon-dev/el-autocomplete/register"),
  "el-dm-badge": () => import("@duskmoon-dev/el-badge/register"),
  "el-dm-bottom-navigation": () => import("@duskmoon-dev/el-bottom-navigation/register"),
  "el-dm-bottom-sheet": () => import("@duskmoon-dev/el-bottom-sheet/register"),
  "el-dm-breadcrumbs": () => import("@duskmoon-dev/el-breadcrumbs/register"),
  "el-dm-button": () => import("@duskmoon-dev/el-button/register"),
  "el-dm-card": () => import("@duskmoon-dev/el-card/register"),
  "el-dm-cascader": () => import("@duskmoon-dev/el-cascader/register"),
  "el-dm-chat": () => import("@duskmoon-dev/el-chat/register"),
  "el-dm-chip": () => import("@duskmoon-dev/el-chip/register"),
  "el-dm-circle-menu": () => import("@duskmoon-dev/el-circle-menu/register"),
  "el-dm-code-block": () => import("@duskmoon-dev/el-code-block/register"),
  "el-dm-code-engine": registerCodeEngineElement,
  "el-dm-datepicker": () => import("@duskmoon-dev/el-datepicker/register"),
  "el-dm-dialog": () => import("@duskmoon-dev/el-dialog/register"),
  "el-dm-drawer": () => import("@duskmoon-dev/el-drawer/register"),
  "el-dm-file-upload": () => import("@duskmoon-dev/el-file-upload/register"),
  "el-dm-form": () => import("@duskmoon-dev/el-form/register"),
  "el-dm-form-group": () => import("@duskmoon-dev/el-form-group/register"),
  "el-dm-input": () => import("@duskmoon-dev/el-input/register"),
  "el-dm-markdown": () => import("@duskmoon-dev/el-markdown/register"),
  "el-dm-markdown-input": () => import("@duskmoon-dev/el-markdown-input/register"),
  "el-dm-menu": () => import("@duskmoon-dev/el-menu/register"),
  "el-dm-navbar": () => import("@duskmoon-dev/el-navbar/register"),
  "el-dm-navigation": () => import("@duskmoon-dev/el-navigation/register"),
  "el-dm-nested-menu": () => import("@duskmoon-dev/el-nested-menu/register"),
  "el-dm-otp-input": () => import("@duskmoon-dev/el-otp-input/register"),
  "el-dm-pagination": () => import("@duskmoon-dev/el-pagination/register"),
  "el-dm-pin-input": () => import("@duskmoon-dev/el-pin-input/register"),
  "el-dm-popover": () => import("@duskmoon-dev/el-popover/register"),
  "el-dm-pro-data-grid": () => import("@duskmoon-dev/el-pro-data-grid/register"),
  "el-dm-progress": () => import("@duskmoon-dev/el-progress/register"),
  "el-dm-segment-control": () => import("@duskmoon-dev/el-segment-control/register"),
  "el-dm-select": () => import("@duskmoon-dev/el-select/register"),
  "el-dm-slider": () => import("@duskmoon-dev/el-slider/register"),
  "el-dm-stepper": () => import("@duskmoon-dev/el-stepper/register"),
  "el-dm-switch": () => import("@duskmoon-dev/el-switch/register"),
  "el-dm-table": () => import("@duskmoon-dev/el-table/register"),
  "el-dm-tabs": () => import("@duskmoon-dev/el-tabs/register"),
  "el-dm-theme-controller": () => import("@duskmoon-dev/el-theme-controller/register"),
  "el-dm-time-input": () => import("@duskmoon-dev/el-time-input/register"),
  "el-dm-tooltip": () => import("@duskmoon-dev/el-tooltip/register")
};

const duskmoonElementSelector = Object.keys(duskmoonElementRegistrars).join(",");
const registeringDuskmoonElements = new Set();
let duskmoonElementRegistrationQueue = Promise.resolve();
const duskmoonVendorImportReady = new Promise((resolve) => setTimeout(resolve, 100));

function duskmoonElementLoadToken() {
  return `${Date.now().toString(36)}-${Math.random().toString(36).slice(2)}`;
}

function duskmoonElementVendorUrl(url) {
  const separator = url.includes("?") ? "&" : "?";
  return `${url}${separator}r=${duskmoonElementLoadToken()}`;
}

function importDuskmoonVendorUrl(url) {
  const checkedUrl = duskmoonElementVendorUrl(url);

  return duskmoonVendorImportReady.then(() => {
    return import(`${checkedUrl}&m=${duskmoonElementLoadToken()}`);
  });
}

function loadDuskmoonRegistrar(registrar) {
  const match = registrar.toString().match(/import\((["'])([^"']+)\1\)/);
  const url = match && match[2];
  const load = url && url.startsWith("/@vendor/")
    ? () => importDuskmoonVendorUrl(url)
    : () => registrar();

  if (registrar.duskmoonBeforeVendorImport) {
    return registrar.duskmoonBeforeVendorImport(load);
  }

  return load();
}

function loadDuskmoonRegistrarWithRetry(registrar) {
  return loadDuskmoonRegistrar(registrar).catch(() => {
    return new Promise((resolve) => setTimeout(resolve, 50)).then(() => {
      return loadDuskmoonRegistrar(registrar);
    });
  });
}

function collectDuskmoonElementTags(root) {
  const tags = new Set();

  if (root.nodeType === Node.ELEMENT_NODE && duskmoonElementRegistrars[root.localName]) {
    tags.add(root.localName);
  }

  if (root.querySelectorAll) {
    root.querySelectorAll(duskmoonElementSelector).forEach((element) => {
      tags.add(element.localName);
    });
  }

  return tags;
}

function queueDuskmoonElementRegistration(tag, registrar) {
  if (customElements.get(tag) || registeringDuskmoonElements.has(tag)) return;

  registeringDuskmoonElements.add(tag);
  duskmoonElementRegistrationQueue = duskmoonElementRegistrationQueue.then(() => {
    if (customElements.get(tag)) return undefined;

    return loadDuskmoonRegistrarWithRetry(registrar).then(() => {
      if (!customElements.get(tag)) {
        registeringDuskmoonElements.delete(tag);
        console.warn("[Duskmoon] Registrar finished without defining " + tag);
      }
    });
  }).catch((error) => {
    registeringDuskmoonElements.delete(tag);
    console.error("[Duskmoon] Failed to register " + tag, error);
  });
}

function registerDuskmoonElements(root = document) {
  collectDuskmoonElementTags(root).forEach((tag) => {
    queueDuskmoonElementRegistration(tag, duskmoonElementRegistrars[tag]);
  });
}

function startDuskmoonElementRegistration() {
  registerDuskmoonElements();

  new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      mutation.addedNodes.forEach((node) => registerDuskmoonElements(node));
    });
  }).observe(document.documentElement, { childList: true, subtree: true });
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", startDuskmoonElementRegistration);
} else {
  startDuskmoonElementRegistration();
}

// Theme switcher (standalone — no LiveView required)
// Mirrors the ThemeSwitcher hook logic for controller-rendered pages.
(function initThemeSwitcher() {
  var darkQuery = window.matchMedia("(prefers-color-scheme: dark)");

  function resolveAutoTheme() {
    return darkQuery.matches ? "moonlight" : "sunshine";
  }

  function applyTheme(theme) {
    var resolved = (!theme || theme === "default") ? resolveAutoTheme() : theme;
    document.documentElement.setAttribute("data-theme", resolved);
  }

  function setup() {
    var saved = localStorage.getItem("theme") || "default";
    applyTheme(saved);

    // Re-apply when OS color scheme changes (only matters in auto mode)
    darkQuery.addEventListener("change", function() {
      var current = localStorage.getItem("theme") || "default";
      if (current === "default") applyTheme("default");
    });

    var radios = document.querySelectorAll(".theme-controller-item");
    radios.forEach(function(radio) {
      radio.checked = radio.value === saved;
      radio.addEventListener("change", function(e) {
        var theme = e.target.value;
        localStorage.setItem("theme", theme);
        applyTheme(theme);
        // Close the <details> dropdown
        var details = e.target.closest("details");
        if (details) details.removeAttribute("open");
      });
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", setup);
  } else {
    setup();
  }
})();

// Clipboard functionality
function fallbackCopyTextToClipboard(text) {
  var textArea = document.createElement("textarea");
  textArea.value = text;
  
  // Avoid scrolling to bottom
  textArea.style.top = "0";
  textArea.style.left = "0";
  textArea.style.position = "fixed";

  document.body.appendChild(textArea);
  textArea.focus();
  textArea.select();

  try {
    var successful = document.execCommand('copy');
    // fallback execCommand is deprecated but acceptable for old browsers
  } catch (err) {
    console.error('Fallback: Oops, unable to copy', err);
  }

  document.body.removeChild(textArea);
}

window.copyTextToClipboard = function(text) {
  if (!navigator.clipboard) {
    fallbackCopyTextToClipboard(text);
    return;
  }
  navigator.clipboard.writeText(text).then(function() {
    console.log('Async: Copying to clipboard was successful!');
  }, function(err) {
    console.error('Async: Could not copy text: ', err);
  });
};

window.showCopyFeedback = function(element) {
  const originalContent = element.innerHTML;
  element.innerHTML = '<span class="text-success">✓</span>';
  setTimeout(() => {
    element.innerHTML = originalContent;
  }, 1000);
};
