import { client } from './clients.ts'
import { EFPListsABI } from 'scripts/abi/EFPLists.ts'
import { EFPListMetadataABI } from 'scripts/abi/EFPListMetadata.ts'
import { EFPAccountMetadataABI } from 'scripts/abi/EFPAccountMetadata.ts'
import { EFPListRegistryABI } from 'scripts/abi/EFPListRegistry.ts'
import { EFPListMinterABI } from 'scripts/abi/EFPListMinter.ts'
import { decodeEventLog } from 'viem'
// @ts-ignore
BigInt.prototype.toJSON = function () {
  return this.toString()
}

/**
   Deployer           : 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38 
   EFPAccountMetadata : 0x5FbDB2315678afecb367f032d93F642f64180aa3 
   EFPListRegistry    : 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 
   EFPListMetadata    : 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 
   EFPLists           : 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9 
   EFPListMinter      : 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707 
 */

const [contracts] = [
  ['EFPAccountMetadata', '0x5FbDB2315678afecb367f032d93F642f64180aa3', EFPAccountMetadataABI],
  ['EFPListRegistry', '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512', EFPListRegistryABI],
  ['EFPListMetadata', '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0', EFPListMetadataABI],
  ['EFPLists', '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9', EFPListsABI],
  ['EFPListMinter', '0x5FC8d32690cc91D4c39d9d3abcBD16989F875707', EFPListMinterABI],
]
async function main() {
  const watchEfpAccountMetadata = client.watchContractEvent({
    abi: EFPAccountMetadataABI,
    address: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
    eventName: 'ValueSet',
    onLogs: (logs) => {
      console.log('\n--- EFPAccountMetadata ---\n')
      logs.map(({ data, topics }) => {
        const _topics = decodeEventLog({
          abi: EFPAccountMetadataABI,
          data,
          topics,
        })
        console.log('Decoded topics:', _topics)
      })
    },
  })

  const watchEfpListRegistry = client.watchContractEvent({
    abi: EFPListRegistryABI,
    address: '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',
    eventName: 'Transfer',
    onLogs: (logs) => {
      console.log('\n--- EFPListRegistry ---\n')
      logs.map(({ data, topics }) => {
        const _topics = decodeEventLog({
          abi: EFPListRegistryABI,
          data,
          topics,
        })
        console.log('Decoded topics:', _topics)
      })
    },
  })

  const watchEfpListMetadata = client.watchContractEvent({
    abi: EFPListMetadataABI,
    address: '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0',
    eventName: 'ValueSet',
    onLogs: (logs) => {
      console.log('\n--- EFPListMetadata ---\n')
      logs.map(({ data, topics }) => {
        const _topics = decodeEventLog({
          abi: EFPListMetadataABI,
          data,
          topics,
        })
        console.log('Decoded topics:', _topics)
      })
    },
  })
}

// const unwatch = client.watchBlocks({
//   onBlock: async (block) => {
//     const receipts = await Promise.all(block.transactions.map((hash) => client.waitForTransactionReceipt({ hash })))
//     console.log(JSON.stringify(receipts, undefined, 2))
//   },
// })
