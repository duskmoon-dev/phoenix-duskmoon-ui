import "phoenix"
import "phoenix_html"
import { LiveSocket } from "phoenix_live_view"

import config from "./config.json"
import "./hooks/clock"
import "./hooks/env-mode"

const pages = import.meta.glob("./pages/*.ts", { eager: true })

window.__duskmoonBundlerFixture = {
  config,
  liveSocket: typeof LiveSocket,
  pages
}

