const clock = window.setInterval(() => {
  window.__duskmoonBundlerClockTicks = (window.__duskmoonBundlerClockTicks ?? 0) + 1
}, 1000)

import.meta.hot?.dispose(() => {
  clearInterval(clock)
})

