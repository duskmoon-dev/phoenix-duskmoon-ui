let shadowStyleWorkaroundInstalled = false;

export function installCodeEngineShadowStyleWorkaround() {
  if (shadowStyleWorkaroundInstalled || typeof Element === "undefined") return;

  const attachShadow = Element.prototype.attachShadow;
  if (!attachShadow) return;

  shadowStyleWorkaroundInstalled = true;
  Element.prototype.attachShadow = function (options) {
    const root = attachShadow.call(this, options);

    if (this.localName === "el-dm-code-engine") {
      // WORKAROUND(upstream): duskmoon-dev/code-engine#9
      // style-mod's shared adopted StyleSet returns an empty instance on later roots.
      // Its head target selects per-root <style> insertion, preserving native adopted
      // sheets for BaseElement and avoiding function names that minification changes.
      Object.defineProperty(root, "head", { configurable: true, value: root });
    }

    return root;
  };
}
