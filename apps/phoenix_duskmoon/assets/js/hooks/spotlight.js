/**
 * Spotlight Hook
 * Handles keyboard shortcut (Cmd+K / Ctrl+K) for opening spotlight search
 */
export const Spotlight = {
  mounted() {
    this.handleKeyDown = this.handleKeyDown.bind(this);
    window.addEventListener('keydown', this.handleKeyDown);
  },

  handleKeyDown(evt) {
    // Cmd+K (Mac) or Ctrl+K (Windows/Linux)
    if ((evt.metaKey || evt.ctrlKey) && evt.code === 'KeyK') {
      evt.preventDefault();
      this.el.showModal();

      // Handle escape key to close
      const handleEscape = (escEvt) => {
        if (escEvt.code === 'Escape') {
          this.el.close();
          window.removeEventListener('keydown', handleEscape);
        }
      };
      window.addEventListener('keydown', handleEscape);
    }
  },

  destroyed() {
    window.removeEventListener('keydown', this.handleKeyDown);
  }
};
