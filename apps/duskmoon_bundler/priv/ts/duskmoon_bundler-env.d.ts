declare const $css: string
declare const $id: string
declare const $message: string
declare const $mod_url: string

declare function renderErrorOverlay(message: string): void

interface ImportMeta {
  hot?: {
    data?: unknown
    accept(callback?: (module?: unknown) => void): void
    dispose(callback: (data?: unknown) => void): void
  }
}

interface Window {
  __duskmoon_bundlerConsoleForwarderInstalled?: boolean
}

declare module '@babel/standalone' {
  export interface BabelTransformResult {
    code?: string
    map?: unknown
  }

  export function registerPreset(name: string, preset: unknown): void
  export function transform(source: string, options: Record<string, unknown>): BabelTransformResult
}

declare module 'babel-preset-solid' {
  const preset: unknown
  export default preset
}

declare module 'svelte/compiler' {
  interface CompileOptions {
    generate?: 'client' | 'server' | false
    dev?: boolean
    css?: 'external' | 'injected'
    [key: string]: unknown
  }

  interface CompileResult {
    js?: { code?: string; map?: unknown }
    css?: { code?: string; map?: unknown }
    warnings?: Array<{ code?: string; message?: string; start?: unknown; end?: unknown }>
  }

  export function compile(source: string, options: CompileOptions): CompileResult
}
