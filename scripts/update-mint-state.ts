#!/usr/bin/env bun
import { clients } from './clients.ts'
import * as abi from '../generated/abi.ts'
import { privateKeyToAccount } from 'viem/accounts'

/**
 * cli usage
 * bun scripts/enable-mint.ts --public-mint|--public-batch|--owner-only|--disabled
 */

const mintStateRecord = {
  '--disabled': 0,
  '--owner-only': 1,
  '--public-mint': 2,
  '--public-batch': 3
}

const [, , command] = process.argv as [string, string, keyof typeof mintStateRecord]

if (!mintStateRecord[command]) throw new Error('Invalid command')

console.info(`\n\nSetting mint state to ${command}: ${mintStateRecord[command]}\n\n`)

main()
  .then(console.log)
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

async function main() {
  return clients.sepolia().writeContract({
    abi: abi.efpListRegistryAbi,
    functionName: 'setMintState',
    address: '0xdD1706b888b33712eaCe4973834508AA85946b32',
    account: privateKeyToAccount(Bun.env.ANVIL_ACCOUNT_PRIVATE_KEY),
    args: [mintStateRecord[command]]
  })
}
