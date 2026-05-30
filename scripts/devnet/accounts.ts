import { mnemonicToAccount, type HDAccount } from 'viem/accounts'

/**
 * The canonical Anvil/Hardhat test mnemonic. The ENS devnet uses the same
 * phrase, so these accounts are funded on both our spawned node and a shared
 * ENS devnet node.
 */
export const DEVNET_MNEMONIC =
  'test test test test test test test test test test test junk' as const

/** Private key for account #0 of {@link DEVNET_MNEMONIC} (the deployer). */
export const DEPLOYER_PRIVATE_KEY =
  '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80' as const

export const ACCOUNT_NAMES = ['deployer', 'alice', 'bob', 'carol', 'dave'] as const

export type AccountName = (typeof ACCOUNT_NAMES)[number]

export function getNamedAccounts(): Record<AccountName, HDAccount> {
  return Object.fromEntries(
    ACCOUNT_NAMES.map((name, index) => [
      name,
      mnemonicToAccount(DEVNET_MNEMONIC, { addressIndex: index })
    ])
  ) as Record<AccountName, HDAccount>
}
