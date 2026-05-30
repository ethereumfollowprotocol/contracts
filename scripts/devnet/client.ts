import {
  createTestClient,
  defineChain,
  getContract,
  http,
  publicActions,
  walletActions,
  type Account,
  type Chain
} from 'viem'
import {
  efpAccountMetadataAbi,
  efpListMinterAbi,
  efpListRecordsAbi,
  efpListRegistryAbi
} from '../../generated/abi.ts'
import type { Deployments, DevnetContracts } from './types.ts'

export function defineDevnetChain(chainId: number, rpcUrl: string, wsUrl: string): Chain {
  return defineChain({
    id: chainId,
    name: `EFP Devnet (${chainId})`,
    nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
    rpcUrls: { default: { http: [rpcUrl], webSocket: [wsUrl] } }
  })
}

export function createDevnetClient({
  chain,
  rpcUrl,
  account
}: {
  chain: Chain
  rpcUrl: string
  account: Account
}) {
  return createTestClient({
    chain,
    mode: 'anvil',
    account,
    transport: http(rpcUrl),
    pollingInterval: 100,
    cacheTime: 0
  })
    .extend(publicActions)
    .extend(walletActions)
}

export type DevnetClient = ReturnType<typeof createDevnetClient>

export function getContracts(client: DevnetClient, deployments: Deployments): DevnetContracts {
  return {
    EFPAccountMetadata: getContract({
      abi: efpAccountMetadataAbi,
      address: deployments.EFPAccountMetadata,
      client
    }),
    EFPListRegistry: getContract({
      abi: efpListRegistryAbi,
      address: deployments.EFPListRegistry,
      client
    }),
    EFPListRecords: getContract({
      abi: efpListRecordsAbi,
      address: deployments.EFPListRecords,
      client
    }),
    EFPListMinter: getContract({
      abi: efpListMinterAbi,
      address: deployments.EFPListMinter,
      client
    })
  }
}
