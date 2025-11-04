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

    // Handle theme changes
    themeControllers.forEach(controller => {
      controller.addEventListener("change", (event) => {
        theme = event.target.value;
        requestAnimationFrame(() => {
          localStorage.setItem("theme", theme);
          // Dispatch event to LiveView if needed
          this.pushEvent("theme_changed", { theme: theme });
        });
      });
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
  }
};
