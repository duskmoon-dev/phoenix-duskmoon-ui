/**
 * ThemeSwitcher Hook
 * Handles theme switching with localStorage persistence
 */
export const ThemeSwitcher = {
  mounted() {
    const serverTheme = this.el.dataset.theme || "";
    let theme = serverTheme || localStorage.getItem("theme") || "default";

    const themeControllers = this.el.querySelectorAll(".theme-controller");

    // Set initial checked state
    themeControllers.forEach(controller => {
      controller.checked = theme === controller.value;
    });

    // Handle theme changes — store references for cleanup
    this._changeListeners = [];
    themeControllers.forEach(controller => {
      const listener = (event) => {
        theme = event.target.value;
        requestAnimationFrame(() => {
          localStorage.setItem("theme", theme);
          this.pushEvent("theme_changed", { theme: theme });
        });
      };
      controller.addEventListener("change", listener);
      this._changeListeners.push({ controller, listener });
    });
  },

  updated() {
    // Sync with server state if changed
    const serverTheme = this.el.dataset.theme;
    if (serverTheme) {
      const themeControllers = this.el.querySelectorAll(".theme-controller");
      themeControllers.forEach(controller => {
        controller.checked = serverTheme === controller.value;
      });
    }
  },

  destroyed() {
    if (this._changeListeners) {
      this._changeListeners.forEach(({ controller, listener }) => {
        controller.removeEventListener("change", listener);
      });
      this._changeListeners = null;
    }
  }
};
