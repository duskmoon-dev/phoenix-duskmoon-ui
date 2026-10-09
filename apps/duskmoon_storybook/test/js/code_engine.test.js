import { expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { pathToFileURL } from "node:url";

const sourcePath = new URL("../../assets/js/code_engine.js", import.meta.url).pathname;
const view = await Bun.file(Bun.resolveSync("@duskmoon-dev/code-engine/view", import.meta.dir)).text();
const styleModule = view.split("// src/core/view/style-mod.ts\n")[1]?.split("// src/core/view/browser.ts")[0];
if (!styleModule) throw new Error("Cannot locate published Code Engine style-mod implementation");
const combinedSource = `${await Bun.file(sourcePath).text()}\n${styleModule}\nexport { StyleModule };`;
const build = await Bun.build({
  entrypoints: ["editor-style-regression"], target: "browser", minify: true,
  plugins: [{
    name: "published-editor-styles",
    setup(builder) {
      builder.onResolve({ filter: /^editor-style-regression$/ }, () => ({
        path: "editor-style-regression", namespace: "regression",
      }));
      builder.onLoad({ filter: /.*/, namespace: "regression" }, () => ({ contents: combinedSource, loader: "js" }));
    },
  }],
});
if (!build.success) throw new AggregateError(build.logs, "Code Engine workaround build failed");

for (const [variant, source] of [
  ["source", combinedSource],
  ["minified", await build.outputs[0].text()],
]) {
  test(`${variant} editor roots mount independent styles and retain native adopted sheets`, async () => {
    const originalElement = globalThis.Element;
    const moduleDir = mkdtempSync(join(tmpdir(), "duskmoon-editor-styles-"));
    const modulePath = join(moduleDir, "editor.mjs");
    writeFileSync(modulePath, source);
    const ownerDocument = {
      createElement: () => ({ textContent: "", parentNode: null }),
      defaultView: { CSSStyleSheet: class { insertRule() {} } },
    };

    class Root {
      #sheets = [];
      children = [];
      ownerDocument = ownerDocument;
      get adoptedStyleSheets() { return this.#sheets; }
      set adoptedStyleSheets(sheets) { this.#sheets = sheets; }
      get firstChild() { return this.children[0]; }
      insertBefore(style) {
        this.children.unshift(style);
        style.parentNode = this;
      }
    }

    class Host {
      constructor(localName) { this.localName = localName; }
      attachShadow(options) {
        this.options = options;
        return new Root();
      }
    }

    globalThis.Element = Host;
    const adoption = Object.getOwnPropertyDescriptor(Root.prototype, "adoptedStyleSheets");

    try {
      const { installCodeEngineShadowStyleWorkaround, StyleModule } = await import(
        pathToFileURL(modulePath).href
      );
      // Reproduce #9 with the shipped implementation before applying the fix.
      const unpatched = [new Host("el-dm-code-engine"), new Host("el-dm-code-engine")];
      const module = new StyleModule({ ".cm-editor": { color: "red" } });
      StyleModule.mount(unpatched[0].attachShadow({ mode: "open" }), [module]);
      expect(() => StyleModule.mount(unpatched[1].attachShadow({ mode: "open" }), [module])).toThrow(TypeError);

      installCodeEngineShadowStyleWorkaround();
      const patchedAttachShadow = Host.prototype.attachShadow;
      installCodeEngineShadowStyleWorkaround();
      expect(Host.prototype.attachShadow).toBe(patchedAttachShadow);

      for (const color of ["red", "blue"]) {
        const host = new Host("el-dm-code-engine");
        const root = host.attachShadow({ mode: "open" });
        const componentSheet = {};
        root.adoptedStyleSheets = [componentSheet];
        const editorStyles = new StyleModule({ ".cm-editor": { color } });
        StyleModule.mount(root, [editorStyles]);
        StyleModule.mount(root, [editorStyles]);
        expect(root.children.map((style) => style.textContent)).toEqual([`${editorStyles.getRules()}\n`]);
        expect(root.adoptedStyleSheets).toEqual([componentSheet]);
        const additionalSheet = {};
        root.adoptedStyleSheets = [...root.adoptedStyleSheets, additionalSheet];
        expect(root.adoptedStyleSheets).toEqual([componentSheet, additionalSheet]);
        expect(host.options).toEqual({ mode: "open" });
      }

      const otherRoot = new Host("el-dm-button").attachShadow({ mode: "closed" });
      otherRoot.adoptedStyleSheets = [{}];
      expect(Object.hasOwn(otherRoot, "head")).toBe(false);
      expect(otherRoot.children).toHaveLength(0);
      expect(otherRoot.adoptedStyleSheets).toHaveLength(1);
      expect(Object.getOwnPropertyDescriptor(Root.prototype, "adoptedStyleSheets")).toEqual(adoption);
    } finally {
      rmSync(moduleDir, { recursive: true });
      if (originalElement === undefined) delete globalThis.Element;
      else globalThis.Element = originalElement;
    }
  });
}
