import { removeStyle as __duskmoon_bundler_removeStyle, updateStyle as __duskmoon_bundler_updateStyle } from './hmr-client'

const __duskmoon_bundler_id = $id
const __duskmoon_bundler_css = $css

__duskmoon_bundler_updateStyle(__duskmoon_bundler_id, __duskmoon_bundler_css)

if (import.meta.hot) {
  import.meta.hot.accept()
  import.meta.hot.dispose(() => __duskmoon_bundler_removeStyle(__duskmoon_bundler_id))
}
