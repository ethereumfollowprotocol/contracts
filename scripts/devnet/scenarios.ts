import type { Account, Address, Hex } from 'viem'
import { encodeFollowOp, encodeListStorageLocation, encodeTagOp } from './encoding.ts'
import type { DevnetEnvironment } from './types.ts'

/** EFPListRegistry.MintState enum. */
export const MintState = {
  Disabled: 0,
  OwnerOnly: 1,
  PublicMint: 2,
  PublicBatch: 3
} as const

async function send(env: DevnetEnvironment, hash: Hex): Promise<void> {
  await env.client.waitForTransactionReceipt({ hash })
}

/** Opens public minting so any account can mint a primary list. */
export async function openPublicMint(env: DevnetEnvironment): Promise<void> {
  const current = await env.contracts.EFPListRegistry.read.getMintState()
  if (current === MintState.PublicMint || current === MintState.PublicBatch) return
  const hash = await env.contracts.EFPListRegistry.write.setMintState([MintState.PublicMint], {
    account: env.deployer
  })
  await send(env, hash)
}

export type MintedList = { tokenId: bigint; slot: bigint; owner: Address; manager: Account }

/**
 * Mints a primary list. The `manager` account becomes the list manager (so it
 * can apply ops), and the NFT is minted to `to` (defaults to the manager).
 */
export async function mintList(
  env: DevnetEnvironment,
  { manager = env.deployer, to }: { manager?: Account; to?: Address } = {}
): Promise<MintedList> {
  const owner = to ?? manager.address
  const tokenId = await env.contracts.EFPListRegistry.read.totalSupply()
  const slot = tokenId

  const listStorageLocation = encodeListStorageLocation({
    chainId: env.chainId,
    listRecords: env.deployments.EFPListRecords,
    slot
  })

  const hash = await env.contracts.EFPListMinter.write.easyMintTo([owner, listStorageLocation], {
    account: manager
  })
  await send(env, hash)

  return { tokenId, slot, owner, manager }
}

/** Applies follow ops for `targets` on `slot`, signed by `manager`. */
export async function follow(
  env: DevnetEnvironment,
  { manager, slot, targets }: { manager: Account; slot: bigint; targets: Address[] }
): Promise<void> {
  if (targets.length === 0) return
  const ops = targets.map(encodeFollowOp)
  const hash = await env.contracts.EFPListRecords.write.applyListOps([slot, ops], { account: manager })
  await send(env, hash)
}

/** Applies a tag op for `target` on `slot`, signed by `manager`. */
export async function tag(
  env: DevnetEnvironment,
  { manager, slot, target, value }: { manager: Account; slot: bigint; target: Address; value: string }
): Promise<void> {
  const hash = await env.contracts.EFPListRecords.write.applyListOps([slot, [encodeTagOp(target, value)]], {
    account: manager
  })
  await send(env, hash)
}

export type Scenario = (env: DevnetEnvironment) => Promise<void>

/** Deploy only — leaves the chain empty. */
const empty: Scenario = async () => {}

/** One list owned by the deployer, following alice and bob. */
const minimal: Scenario = async (env) => {
  await openPublicMint(env)
  const { slot } = await mintList(env, { manager: env.deployer })
  await follow(env, {
    manager: env.deployer,
    slot,
    targets: [env.accounts.alice.address, env.accounts.bob.address]
  })
}

/** A small social graph: alice, bob, carol each mint a list and follow peers. */
const demoGraph: Scenario = async (env) => {
  await openPublicMint(env)
  const peers = ['alice', 'bob', 'carol'] as const

  for (const name of peers) {
    const manager = env.accounts[name]
    const { slot } = await mintList(env, { manager })
    const targets = peers
      .filter((other) => other !== name)
      .map((other) => env.accounts[other].address)
    await follow(env, { manager, slot, targets })
    await tag(env, { manager, slot, target: env.accounts.dave.address, value: 'efp' })
  }
}

export const scenarios = { empty, minimal, demoGraph } satisfies Record<string, Scenario>

export type ScenarioName = keyof typeof scenarios

export function isScenarioName(value: string): value is ScenarioName {
  return value in scenarios
}
