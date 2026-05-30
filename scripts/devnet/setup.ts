import { createPublicClient, http, type Hex } from 'viem'
import { startAnvil } from './anvil.ts'
import { DEPLOYER_PRIVATE_KEY, getNamedAccounts } from './accounts.ts'
import { createDevnetClient, defineDevnetChain, getContracts } from './client.ts'
import { deployContracts, saveDeployments } from './deploy.ts'
import type { AnvilHandle, DevnetEnvironment, SetupDevnetOptions } from './types.ts'

function wsFromHttp(rpcUrl: string): string {
  return rpcUrl.replace(/^http/, 'ws')
}

async function waitForNode(rpcUrl: string, timeoutMs = 60_000): Promise<number> {
  const probe = createPublicClient({ transport: http(rpcUrl) })
  const deadline = Date.now() + timeoutMs
  let lastError: unknown
  while (Date.now() < deadline) {
    try {
      return await probe.getChainId()
    } catch (error) {
      lastError = error
      await new Promise((resolve) => setTimeout(resolve, 500))
    }
  }
  throw new Error(`Node at ${rpcUrl} not reachable within ${timeoutMs}ms: ${String(lastError)}`)
}

/**
 * Boots an EFP devnet and returns a ready-to-use environment.
 *
 * Two modes:
 * - **standalone**: spawns a local anvil via prool (default).
 * - **attached**: pass `rpcUrl` to deploy EFP onto an already-running node,
 *   e.g. the ENS devnet (`http://devnet:8545`). The node is left running on
 *   shutdown in this mode.
 */
export async function setupDevnet(options: SetupDevnetOptions = {}): Promise<DevnetEnvironment> {
  const {
    rpcUrl: externalRpcUrl,
    port = 8545,
    chainId: requestedChainId = 31337,
    host = '127.0.0.1',
    autoMine = true,
    procLog = false,
    saveDeployments: persist = false,
    quiet = true
  } = options

  const external = Boolean(externalRpcUrl)
  let anvil: AnvilHandle | null = null
  let rpcUrl: string
  let wsUrl: string
  let chainId: number

  if (externalRpcUrl) {
    rpcUrl = externalRpcUrl
    wsUrl = wsFromHttp(externalRpcUrl)
    chainId = await waitForNode(rpcUrl)
  } else {
    anvil = await startAnvil({ port, chainId: requestedChainId, host, autoMine, procLog })
    rpcUrl = anvil.rpcUrl
    wsUrl = anvil.wsUrl
    chainId = await waitForNode(rpcUrl)
  }

  const accounts = getNamedAccounts()
  const chain = defineDevnetChain(chainId, rpcUrl, wsUrl)
  const client = createDevnetClient({ chain, rpcUrl, account: accounts.deployer })

  const deployments = await deployContracts({
    rpcUrl,
    chainId,
    privateKey: DEPLOYER_PRIVATE_KEY as Hex,
    quiet
  })

  if (persist) {
    const file = await saveDeployments(deployments)
    if (!quiet) console.log('Saved deployments to', file)
  }

  const contracts = getContracts(client, deployments)

  return {
    rpcUrl,
    wsUrl,
    chainId,
    external,
    client,
    accounts,
    deployer: accounts.deployer,
    deployments,
    contracts,
    snapshot: () => client.snapshot(),
    revert: (id) => client.revert({ id }),
    mine: (blocks = 1) => client.mine({ blocks }),
    shutdown: async () => {
      if (anvil) await anvil.stop()
    }
  }
}
