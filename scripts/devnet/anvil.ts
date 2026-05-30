import { Instance } from 'prool'
import type { AnvilHandle } from './types.ts'
import { DEVNET_MNEMONIC } from './accounts.ts'

export async function startAnvil({
  port,
  chainId,
  host,
  autoMine,
  procLog
}: {
  port: number
  chainId: number
  host: string
  autoMine: boolean
  procLog: boolean
}): Promise<AnvilHandle> {
  // NOTE: do not pass `silent: true` — prool resolves `start()` by waiting for
  // anvil's "Listening on" stdout message, which `silent` would suppress.
  const instance = Instance.anvil({
    port,
    chainId,
    host,
    mnemonic: DEVNET_MNEMONIC,
    accounts: 10,
    ...(autoMine ? { blockTime: 1 } : {})
  })

  if (procLog) {
    instance.on('message', (message) => process.stdout.write(message))
  }

  const stopFn = await instance.start()
  const rpcHost = host === '0.0.0.0' ? '127.0.0.1' : host

  return {
    rpcUrl: `http://${rpcHost}:${port}`,
    wsUrl: `ws://${rpcHost}:${port}`,
    chainId,
    stop: async () => {
      await instance.stop()
      await stopFn()
    }
  }
}
