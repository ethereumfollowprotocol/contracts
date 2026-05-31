import { mkdir, readFile, writeFile } from 'node:fs/promises'
import path from 'node:path'
import { getAddress, isAddress, type Hex } from 'viem'
import type { ContractName, Deployments } from './types.ts'

const CONTRACT_NAMES: ContractName[] = [
  'EFPAccountMetadata',
  'EFPListRegistry',
  'EFPListRecords',
  'EFPListMinter',
  'TokenURIProvider'
]

function broadcastPath(chainId: number) {
  return path.join(process.cwd(), 'broadcast', 'deploy.s.sol', String(chainId), 'run-latest.json')
}

export function deploymentPath(chainId: number) {
  return path.join(process.cwd(), 'deployments', `devnet-${chainId}.json`)
}

/**
 * Runs the existing, unmodified `scripts/deploy.s.sol` against `rpcUrl` and
 * reads the resulting addresses out of Forge's broadcast artifact. We do not
 * touch the deploy scripts so the live/reproducible deployment stays identical.
 */
export async function deployContracts({
  rpcUrl,
  chainId,
  privateKey,
  quiet = true
}: {
  rpcUrl: string
  chainId: number
  privateKey: Hex
  quiet?: boolean
}): Promise<Deployments> {
  // deploy.s.sol broadcasts with `vm.startBroadcast(vm.envUint('PRIVATE_KEY'))`,
  // so the key is passed via the env var only — never as a CLI arg, which would
  // otherwise be visible to other users via `ps`/`/proc/<pid>/cmdline`.
  const proc = Bun.spawn(['forge', 'script', 'scripts/deploy.s.sol', '--rpc-url', rpcUrl, '--broadcast', '--slow'], {
    cwd: process.cwd(),
    stdout: quiet ? 'ignore' : 'inherit',
    stderr: 'inherit',
    env: {
      ...process.env,
      PRIVATE_KEY: privateKey,
      FOUNDRY_DISABLE_NIGHTLY_WARNING: 'true'
    }
  })

  const exitCode = await proc.exited
  if (exitCode !== 0) {
    throw new Error(`forge deploy exited with code ${exitCode}`)
  }

  return readDeploymentsFromBroadcast(chainId)
}

export async function readDeploymentsFromBroadcast(chainId: number): Promise<Deployments> {
  const raw = await readFile(broadcastPath(chainId), 'utf8')
  const artifact = JSON.parse(raw) as {
    transactions: Array<{ transactionType: string; contractName: string | null; contractAddress: string | null }>
  }

  const found = new Map<string, string>()
  for (const tx of artifact.transactions) {
    if (tx.transactionType === 'CREATE' && tx.contractName && tx.contractAddress) {
      if (!found.has(tx.contractName)) found.set(tx.contractName, tx.contractAddress)
    }
  }

  const deployments = { chainId } as Deployments
  for (const name of CONTRACT_NAMES) {
    const address = found.get(name)
    if (!address || !isAddress(address)) {
      throw new Error(`Deployment for ${name} not found in broadcast artifact (chainId ${chainId})`)
    }
    deployments[name] = getAddress(address)
  }

  return deployments
}

export async function saveDeployments(deployments: Deployments): Promise<string> {
  const file = deploymentPath(deployments.chainId)
  await mkdir(path.dirname(file), { recursive: true })
  await writeFile(file, `${JSON.stringify(deployments, null, 2)}\n`)
  return file
}
