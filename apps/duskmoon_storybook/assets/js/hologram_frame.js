/** Keep the isolated Hologram document sized and themed by its Phoenix host. */
export const DuskmoonHologramFrame = {
  mounted() {
    this.syncTheme = () => {
      const root = this.el.contentDocument?.documentElement;
      const theme = this.el.ownerDocument.documentElement.dataset.theme;
      if (root && theme && root.dataset.theme !== theme) root.dataset.theme = theme;
    };

    this.themeObserver = new MutationObserver(this.syncTheme);
    this.themeObserver.observe(this.el.ownerDocument.documentElement, {
      attributes: true,
      attributeFilter: ["data-theme"],
    });

    this.onLoad = () => {
      this.resizeObserver?.disconnect();
      this.frameThemeObserver?.disconnect();
      const frameDocument = this.el.contentDocument;
      if (!frameDocument?.body || frameDocument.URL === "about:blank") return;

      this.syncTheme();
      this.frameThemeObserver = new MutationObserver(this.syncTheme);
      this.frameThemeObserver.observe(frameDocument.documentElement, {
        attributes: true,
        attributeFilter: ["data-theme"],
      });

      const resize = () => {
        this.el.style.height = `${Math.ceil(frameDocument.body.getBoundingClientRect().height)}px`;
      };
      this.resizeObserver = new ResizeObserver(resize);
      this.resizeObserver.observe(frameDocument.body);
      resize();
    };

    this.el.addEventListener("load", this.onLoad);
    this.onLoad();
  },

  updated() {
    this.onLoad();
  },

  destroyed() {
    this.el.removeEventListener("load", this.onLoad);
    this.resizeObserver?.disconnect();
    this.themeObserver.disconnect();
    this.frameThemeObserver?.disconnect();
  },
};
