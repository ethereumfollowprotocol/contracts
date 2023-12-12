// this file takes the compiler output for solidity in out/ContractName.sol/ContractName.json
// and takes the abi and copies it into a typescript file of the form:
// ```
// export const ContractNameABI = [
// ...
// ] as const
// ```

import fs from 'node:fs'
import path from 'node:path'

const contractNames = ['EFPAccountMetadata', 'EFPListMinter', 'EFPListRecords', 'EFPListRegistry']

const __dirname = path.dirname(new URL(import.meta.url).pathname)

const projectDir = path.resolve(__dirname, '..')
const inputDir = '../out'

const outputDirs = [
  path.resolve(projectDir, 'generated/abi'),
  path.resolve(projectDir, '..', 'indexer/src/abi/generated'),
]

for (const contractName of contractNames) {
  const contract = require(`${inputDir}/${contractName}.sol/${contractName}.json`)
  const abi = JSON.stringify(contract.abi, null, 2)
  const contents = `export const ${contractName}ABI = ${abi} as const\n`

  for (const outputDir of outputDirs) {
    const abiOutputFilePath = path.resolve(outputDir, `${contractName}.ts`)
    console.log(`${abiOutputFilePath}`)
    fs.writeFileSync(abiOutputFilePath, contents)
  }

  console.log()
}

// generate index.ts
// export * from './EFPAccountMetadata'
// export * from './EFPListMinter'
// export * from './EFPListRegistry'
// export * from './EFPListRecords'

const contents = `${contractNames.map((name) => `export * from './${name}'`).join('\n')}\n`
for (const outputDir of outputDirs) {
  const abiOutputFilePath = path.resolve(outputDir, `index.ts`)
  console.log(`${abiOutputFilePath}`)
  fs.writeFileSync(abiOutputFilePath, contents)
}
