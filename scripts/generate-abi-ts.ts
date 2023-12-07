// this file takes the compiler output for solidity in out/ContractName.sol/ContractName.json
// and takes the abi and copies it into a typescript file of the form:
// ```
// export const ContractNameABI = [
// ...
// ] as const
// ```

import fs from 'node:fs'
import path from 'node:path'

const contractNames = ['EFPAccountMetadata', 'EFPListMetadata', 'EFPListMinter', 'EFPListRecords', 'EFPListRegistry']

const __dirname = path.dirname(new URL(import.meta.url).pathname)

const projectDir = path.resolve(__dirname, '..')
const inputDir = '../out'
const outputDir = '../out'

// _dirname is the directory of the current file

for (const contractName of contractNames) {
  const contract = require(`${inputDir}/${contractName}.sol/${contractName}.json`)
  const abi = JSON.stringify(contract.abi, null, 2)
  const contents = `export const ${contractName}ABI = ${abi} as const\n`
  const outputFile = path.resolve(`${__dirname}/${outputDir}/${contractName}.ts`)
  console.log(outputFile)
  fs.writeFileSync(outputFile, contents)

  // copy ABI definition to the indexer project
  const indexerProjectDir = path.resolve(projectDir, '..', 'indexer')
  const indexerOutputDir = path.resolve(indexerProjectDir, 'src/abi/generated')
  const indexerOutputFilePath = path.resolve(indexerOutputDir, `${contractName}.ts`)
  console.log(`${indexerOutputFilePath}`)
  fs.writeFileSync(indexerOutputFilePath, contents)

  console.log()
}

// generate index.ts in the indexer project
// export * from './EFPAccountMetadata'
// export * from './EFPListMetadata'
// export * from './EFPListMinter'
// export * from './EFPListRegistry'
// export * from './EFPListRecords'

const indexerOutputDir = path.resolve(projectDir, '..', 'indexer', 'src/abi/generated')
const indexerOutputFilePath = path.resolve(indexerOutputDir, `index.ts`)
console.log(`${indexerOutputFilePath}`)
const indexerOutput = contractNames.map(name => `export * from './${name}'`).join('\n')
fs.writeFileSync(indexerOutputFilePath, indexerOutput)
