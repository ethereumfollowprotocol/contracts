import { foundry } from 'viem/chains'
import { privateKeyToAccount } from 'viem/accounts'
import { http, createTestClient, publicActions, walletActions, isHex } from 'viem'

const anvilAccountPrivateKey = process.env.ANVIL_ACCOUNT_PRIVATE_KEY

if (!isHex(anvilAccountPrivateKey)) {
  throw new Error('ANVIL_ACCOUNT_PRIVATE_KEY env variable is not set. Check README.md')
}

export const account = privateKeyToAccount(anvilAccountPrivateKey)

export const client = createTestClient({
  chain: foundry,
  mode: 'anvil',
  transport: http('http://0.0.0.0:8545'),
  account,
})
  .extend(publicActions)
  .extend(walletActions)
