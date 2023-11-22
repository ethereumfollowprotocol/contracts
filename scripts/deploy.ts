import bun from 'bun'
import fs from 'node:fs'
import path from 'node:path'
import type { Address } from 'viem'
import { client } from 'scripts/client.ts'

deployContracts()
  .then(console.log)
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })

async function deployContracts() {
  const contractDirectories = fs
    .readdirSync(path.resolve(import.meta.dir, '../out/beta'))
    .filter((directory) => !directory.endsWith('.t.sol'))

  const deployedContracts: Array<[contractName: string, transactionHash: Address, abi: readonly any[]]> = []

  for await (const contractDirectory of contractDirectories) {
    const [contractName] = contractDirectory.split('.')
    const filePath = path.resolve(import.meta.dir, `../out/beta/${contractDirectory}/${contractName}.json`)
    const contractJson = await bun.file(filePath).json()
    const abi = contractJson.abi as readonly any[]

    // @ts-expect-error
    const hash = await client.deployContract({
      abi,
      account: client.account,
      bytecode: contractJson.bytecode.object,
    })

    deployedContracts.push([contractDirectory, hash, abi])
  }

  const contractAddresses = await Promise.all(
    deployedContracts.map(([, hash]) => client.waitForTransactionReceipt({ hash }))
  )

  const deployContracts = deployedContracts.map(([contractName, hash, abi], index) => ({
    contractName,
    transactionHash: hash,
    contractAddress: contractAddresses[index].contractAddress,
    abi,
  }))

  const write = await bun.write('./out/anvil-deployed-contracts.json', JSON.stringify(deployContracts, undefined, 2), {
    mode: 0o644,
  })

  if (!write) throw new Error('Failed to write anvil-deployed-contracts.json')

  console.log(JSON.stringify(deployContracts, undefined, 2))
}
