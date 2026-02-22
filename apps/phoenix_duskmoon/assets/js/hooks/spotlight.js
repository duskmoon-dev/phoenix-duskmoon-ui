/**
 * Spotlight Hook
 * Handles keyboard shortcut (Cmd+K / Ctrl+K) for opening spotlight search
 */
export const Spotlight = {
  mounted() {
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.handleEscape = this.handleEscape.bind(this);
    window.addEventListener('keydown', this.handleKeyDown);
  },

  handleKeyDown(evt) {
    // Cmd+K (Mac) or Ctrl+K (Windows/Linux)
    if ((evt.metaKey || evt.ctrlKey) && evt.code === 'KeyK') {
      evt.preventDefault();
      this.el.showModal();
      window.removeEventListener('keydown', this.handleEscape);
      window.addEventListener('keydown', this.handleEscape);
    }
  },

  handleEscape(escEvt) {
    if (escEvt.code === 'Escape') {
      this.el.close();
      window.removeEventListener('keydown', this.handleEscape);
    }
  },

  destroyed() {
    window.removeEventListener('keydown', this.handleKeyDown);
    window.removeEventListener('keydown', this.handleEscape);
  }
};
