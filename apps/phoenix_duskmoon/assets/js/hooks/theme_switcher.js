/**
 * ThemeSwitcher Hook
 * Handles theme switching with localStorage persistence.
 * Works with @duskmoon-dev/core's theme-controller-dropdown CSS component.
 *
 * Sets data-theme on document.documentElement so CSS attribute selectors
 * like [data-theme="sunshine"] activate the correct theme.
 */

const darkQuery = window.matchMedia("(prefers-color-scheme: dark)");

function resolveAutoTheme() {
  return darkQuery.matches ? "moonlight" : "sunshine";
}

function applyTheme(theme) {
  const resolved = (!theme || theme === "default") ? resolveAutoTheme() : theme;
  document.documentElement.setAttribute("data-theme", resolved);
}

export const ThemeSwitcher = {
  mounted() {
    const serverTheme = this.el.dataset.theme || "";
    let theme = serverTheme || localStorage.getItem("theme") || "default";

    // Apply theme to document root so CSS selectors activate
    applyTheme(theme);

    const themeInputs = this.el.querySelectorAll(".theme-controller-item");

    // Set initial checked state from localStorage or server
    themeInputs.forEach(input => {
      input.checked = theme === input.value;
    });

    // Re-apply when OS color scheme changes (only matters in auto mode)
    this._mediaListener = () => {
      const current = localStorage.getItem("theme") || "default";
      if (current === "default") applyTheme("default");
    };
    darkQuery.addEventListener("change", this._mediaListener);

    // Handle theme changes — store references for cleanup
    this._changeListeners = [];
    themeInputs.forEach(input => {
      const listener = (event) => {
        theme = event.target.value;
        requestAnimationFrame(() => {
          applyTheme(theme);
          localStorage.setItem("theme", theme);
          this.pushEvent("theme_changed", { theme: theme });
          // Close the <details> dropdown after selection
          this.el.removeAttribute("open");
        });
      };
      input.addEventListener("change", listener);
      this._changeListeners.push({ element: input, listener });
    });
  },

  updated() {
    // Sync with server state if changed
    const serverTheme = this.el.dataset.theme;
    if (serverTheme) {
      applyTheme(serverTheme);
      const themeInputs = this.el.querySelectorAll(".theme-controller-item");
      themeInputs.forEach(input => {
        input.checked = serverTheme === input.value;
      });
    }
  },

  destroyed() {
    if (this._changeListeners) {
      this._changeListeners.forEach(({ element, listener }) => {
        element.removeEventListener("change", listener);
      });
      this._changeListeners = null;
    }
    if (this._mediaListener) {
      darkQuery.removeEventListener("change", this._mediaListener);
      this._mediaListener = null;
    }
  }
};
