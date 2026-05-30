import type { Address, GetContractReturnType, Hex } from 'viem'
import type { HDAccount } from 'viem/accounts'
import type {
  efpAccountMetadataAbi,
  efpListMinterAbi,
  efpListRecordsAbi,
  efpListRegistryAbi
} from '../../generated/abi.ts'
import type { DevnetClient } from './client.ts'

export type ContractName =
  | 'EFPAccountMetadata'
  | 'EFPListRegistry'
  | 'EFPListRecords'
  | 'EFPListMinter'
  | 'TokenURIProvider'

export type Deployments = Record<ContractName, Address> & { chainId: number }

export type DevnetContracts = {
  EFPAccountMetadata: GetContractReturnType<typeof efpAccountMetadataAbi, DevnetClient, Address>
  EFPListRegistry: GetContractReturnType<typeof efpListRegistryAbi, DevnetClient, Address>
  EFPListRecords: GetContractReturnType<typeof efpListRecordsAbi, DevnetClient, Address>
  EFPListMinter: GetContractReturnType<typeof efpListMinterAbi, DevnetClient, Address>
}

export type AnvilHandle = {
  rpcUrl: string
  wsUrl: string
  chainId: number
  stop: () => Promise<void>
}

export type DevnetEnvironment = {
  /** JSON-RPC endpoints of the devnet node. */
  rpcUrl: string
  wsUrl: string
  chainId: number
  /** True when EFP was deployed onto a pre-existing node (e.g. the ENS devnet). */
  external: boolean
  /** viem client (public + wallet + test actions), defaulting to the deployer. */
  client: DevnetClient
  /** Named, funded dev accounts derived from the standard test mnemonic. */
  accounts: Record<string, HDAccount>
  deployer: HDAccount
  /** Deployed contract addresses. */
  deployments: Deployments
  /** Bound viem contract instances. */
  contracts: DevnetContracts
  /** Take an anvil state snapshot; returns the snapshot id. */
  snapshot: () => Promise<Hex>
  /** Revert to a previously taken snapshot. */
  revert: (id: Hex) => Promise<void>
  /** Mine `blocks` blocks (default 1). */
  mine: (blocks?: number) => Promise<void>
  /** Stop the node (if we own it) and release resources. */
  shutdown: () => Promise<void>
}

export type SetupDevnetOptions = {
  /** Connect to an existing node instead of spawning one (e.g. the ENS devnet). */
  rpcUrl?: string
  /** Anvil port when spawning a node. @default 8545 */
  port?: number
  /** Chain id when spawning a node. @default 31337 */
  chainId?: number
  /** Host to bind when spawning a node. @default 127.0.0.1 */
  host?: string
  /**
   * Interval mining period in seconds when spawning a node. `0` keeps Anvil's
   * default instant automining (mine on each transaction). @default 1
   */
  blockTime?: number
  /** Forward anvil stdout/stderr to the console. @default false */
  procLog?: boolean
  /** Persist `deployments/devnet-<chainId>.json` for downstream consumers. @default false */
  saveDeployments?: boolean
  /** Suppress the deploy script's stdout. @default true */
  quiet?: boolean
}
