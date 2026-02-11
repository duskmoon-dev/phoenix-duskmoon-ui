/**
 * PageHeader Hook
 * Handles IntersectionObserver for showing/hiding nav based on header visibility
 */
export const PageHeader = {
  mounted() {
    const navId = this.el.dataset.navId;
    const navEl = document.getElementById(navId);

    if (!navEl) {
      console.warn(`PageHeader hook: Nav element with id "${navId}" not found`);
      return;
    }

    // Create threshold list for smooth transitions
    const thresholds = [];
    for (let i = 0; i <= 10; i++) {
      thresholds.push(i / 10);
    }

    const options = {
      root: null,
      rootMargin: "0px",
      threshold: thresholds,
    };

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        const intersectionRatio = entry.intersectionRatio;

        if (intersectionRatio <= 0.5) {
          navEl.classList.remove('hidden');
          navEl.setAttribute('aria-hidden', 'false');
          navEl.style.opacity = 1 - intersectionRatio;
        } else {
          navEl.classList.add('hidden');
          navEl.setAttribute('aria-hidden', 'true');
        }
      });
    }, options);

    this.observer.observe(this.el);
  },

  destroyed() {
    if (this.observer) {
      this.observer.disconnect();
    }
  }
};
