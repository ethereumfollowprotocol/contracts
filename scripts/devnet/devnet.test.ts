import { afterAll, beforeAll, describe, expect, test } from 'bun:test'
import type { Hex } from 'viem'
import { setupDevnet } from './setup.ts'
import { follow, mintList, openPublicMint } from './scenarios.ts'
import type { DevnetEnvironment } from './types.ts'

// NOTE: spawning anvil + deploying via forge takes longer than bun's default
// 5s hook timeout — run with `bun test --timeout 120000` (see `devnet:test`).
describe('efp devnet', () => {
  let env: DevnetEnvironment
  let baseline: Hex

  beforeAll(async () => {
    // Spawns an ephemeral anvil on a non-default port and deploys EFP onto it.
    env = await setupDevnet({ port: 8645, chainId: 31337 })
    await openPublicMint(env)
    baseline = await env.snapshot()
  })

  afterAll(async () => {
    await env?.shutdown()
  })

  test('deploys all contracts', () => {
    expect(env.deployments.EFPListRegistry).toMatch(/^0x[0-9a-fA-F]{40}$/)
    expect(env.deployments.EFPListMinter).toMatch(/^0x[0-9a-fA-F]{40}$/)
  })

  test('mints a list and records follows', async () => {
    const { tokenId, slot } = await mintList(env, { manager: env.accounts.alice })
    expect(await env.contracts.EFPListRegistry.read.ownerOf([tokenId])).toBe(env.accounts.alice.address)

    await follow(env, {
      manager: env.accounts.alice,
      slot,
      targets: [env.accounts.bob.address, env.accounts.carol.address]
    })

    expect(await env.contracts.EFPListRecords.read.getListOpCount([slot])).toBe(2n)

    // Roll back to the clean post-deploy snapshot for the next test.
    await env.revert(baseline)
    baseline = await env.snapshot()
  })

  test('snapshot/revert isolates state', async () => {
    expect(await env.contracts.EFPListRegistry.read.totalSupply()).toBe(0n)
  })
})
