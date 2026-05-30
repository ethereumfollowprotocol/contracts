import { Instance } from 'prool'
import type { AnvilHandle } from './types.ts'
import { DEVNET_MNEMONIC } from './accounts.ts'

export async function startAnvil({
  port,
  chainId,
  host,
  blockTime,
  procLog
}: {
  port: number
  chainId: number
  host: string
  /** Interval mining period in seconds. `0` keeps Anvil's default instant automining. */
  blockTime: number
  procLog: boolean
}): Promise<AnvilHandle> {
  // NOTE: do not pass `silent: true` — prool resolves `start()` by waiting for
  // anvil's "Listening on" stdout message, which `silent` would suppress.
  //
  // `blockTime > 0` => interval mining (a block every N seconds).
  // `blockTime === 0` => omit the flag, leaving Anvil's default instant
  // automining (mine immediately on each transaction).
  const instance = Instance.anvil({
    port,
    chainId,
    host,
    mnemonic: DEVNET_MNEMONIC,
    accounts: 10,
    ...(blockTime > 0 ? { blockTime } : {})
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
