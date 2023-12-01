#!/usr/bin/env bun
import type { Address } from 'viem'
import { account, client } from './clients.ts'
import { EFPListRegistryABI } from 'scripts/abi/EFPListRegistry.ts'

async function mint(contractAddress: Address) {
  const setApprovalHash = await client.writeContract({
    abi: [],
    functionName: '',
    account: account.address,
    address: contractAddress,
    args: [account.address, true],
  })

  console.log('setApprovalForAll hash:', setApprovalHash)

  const mintHash = await client.writeContract({
    abi: EFPListRegistryABI,
    functionName: 'mint',
    account: account.address,
    address: contractAddress,
  })

  console.log('mint hash:', mintHash)
}

mint('0x9A86494Ba45eE1f9EEed9cFC0894f6C5d13a1F0b').catch((error) => {
  console.error(JSON.stringify(error, undefined, 2))
  process.exit(1)
})
