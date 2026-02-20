/**
 * ThemeSwitcher Hook
 * Handles theme switching with localStorage persistence.
 * Works with @duskmoon-dev/core's theme-controller-dropdown CSS component.
 */
export const ThemeSwitcher = {
  mounted() {
    const serverTheme = this.el.dataset.theme || "";
    let theme = serverTheme || localStorage.getItem("theme") || "default";

    const themeInputs = this.el.querySelectorAll(".theme-controller-item");

    // Set initial checked state from localStorage or server
    themeInputs.forEach(input => {
      input.checked = theme === input.value;
    });

    // Handle theme changes — store references for cleanup
    this._changeListeners = [];
    themeInputs.forEach(input => {
      const listener = (event) => {
        theme = event.target.value;
        requestAnimationFrame(() => {
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
  }
};
