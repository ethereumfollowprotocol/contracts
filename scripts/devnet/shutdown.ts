const finalizers: Array<() => void | Promise<void>> = []
let shuttingDown = false

export function onShutdown(finalizer: () => void | Promise<void>) {
  finalizers.push(finalizer)
}

async function shutdown(signal?: string, exitCode = 0) {
  if (shuttingDown) return
  shuttingDown = true

  if (signal) console.log(`\nShutting down (${signal})...`)

  await Promise.allSettled(finalizers.map((fn) => fn()))
  process.exit(exitCode)
}

export function registerShutdownHandlers() {
  process.once('SIGINT', () => void shutdown('SIGINT'))
  process.once('SIGTERM', () => void shutdown('SIGTERM'))
  process.once('uncaughtException', async (error) => {
    console.error(error)
    await shutdown('uncaughtException', 1)
  })
}

export async function keepAlive() {
  await new Promise<void>(() => {})
}
