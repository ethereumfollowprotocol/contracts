#!/usr/bin/env node
import { account } from 'scripts/clients'
import { createTestClient, http, publicActions, walletActions } from 'viem'
import { foundry } from 'viem/chains'

createTestClient({
  chain: foundry,
  mode: 'anvil',
  transport: http('http://0.0.0.0:8545'),
  account,
})
  .extend(publicActions)
  .extend(walletActions)
  .watchBlocks({
    onBlock: (block) => {
      console.log('Block:', block)
    },
  })
