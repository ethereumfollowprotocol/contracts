// this file takes the compiler output for solidity in out/ContractName.sol/ContractName.json
// and takes the abi and copies it into a typescript file of the form:
// ```
// import type { Abi } from 'viem'
//
// export const ContractNameABI: Abi = [
// ...
// ] as const
// ```

import fs from 'fs';
import path from 'path';

const contractNames = [
    'EFPAccountMetadata',
    'EFPListMetadata',
    'EFPListMinter',
    'EFPListRecords',
    'EFPListRegistry'
]

const projectDir = path.resolve(__dirname, '..')
const inputDir = '../out'
const outputDir = '../out'

// _dirname is the directory of the current file

for (const contractName of contractNames) {
    const contract = require(`${inputDir}/${contractName}.sol/${contractName}.json`)
    const abi = JSON.stringify(contract.abi, null, 2)
    const output = `import type { Abi } from 'viem'\n\nexport const ${contractName}ABI: Abi = ${abi} as const\n`
    const relPath = `${outputDir}/${contractName}.ts`
    const absOutputFilePath = `${__dirname}/${relPath}`
    // in order to remove the "foo/../bar" and replace to "/bar"
    // we can use the function path.resolve
    const realPath = path.resolve(absOutputFilePath)
    console.log(`${realPath}`)
    fs.writeFileSync(realPath, output)

    // copy ABI definition to the indexer project
    const indexerProjectDir = path.resolve(projectDir, '..', 'indexer')
    const indexerOutputDir = path.resolve(indexerProjectDir, 'src/abi/generated')
    const indexerOutputFilePath = path.resolve(indexerOutputDir, `${contractName}.ts`)
    console.log(`${indexerOutputFilePath}`)
    fs.writeFileSync(indexerOutputFilePath, output)

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
