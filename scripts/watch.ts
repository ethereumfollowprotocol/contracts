import { EFPAccountMetadataABI, EFPListMinterABI, EFPListRecordsABI, EFPListRegistryABI } from '#/generated/abi'
import { decodeEventLog } from 'viem'
import { clients } from './clients.ts'
import './types.ts'

console.log('watch.ts')

main().catch((error) => {
  console.error('watch.ts error:', error instanceof Error ? error.message : error)
  process.exit(1)
})

/**
   Deployer           : 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
   EFPAccountMetadata : 0x5FbDB2315678afecb367f032d93F642f64180aa3
   EFPListRegistry    : 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
   EFPListMetadata    : 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
   EFPListRecords     : 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
   EFPListMinter      : 0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9
 */

async function main() {
  const client = clients.localhostAnvil()

  // client.watchEvent({
  //   address: '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',
  //   event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'),
  //   onLogs: (logs) => {
  //     console.log('Watched event logs:', logs)
  //   },
  //   onError: (error) => {
  //     console.log('watch.ts error:', error)
  //   },
  // })

  client.watchContractEvent({
    abi: EFPAccountMetadataABI,
    address: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
    // eventName: 'ValueSet',
    onError: (error) => {
      console.log('EFPAccountMetadataABI error:', error)
    },
    onLogs: (logs) => {
      console.log('\n--- EFPAccountMetadata ---\n')
      logs.map(({ data, topics }) => {
        const _topics = decodeEventLog({
          abi: EFPAccountMetadataABI,
          data,
          topics,
        })
        console.log('[EFPAccountMetadata] Decoded topics:', JSON.stringify(_topics, undefined, 2))
      })
    },
  })

  client.watchContractEvent({
    abi: EFPListRegistryABI,
    address: '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',
    // eventName: 'Transfer',
    onError: (error) => {
      console.log('EFPListRegistryABI error:', error)
    },
    onLogs: (logs) => {
      console.log('\n--- EFPListRegistry ---\n')
      logs.map(({ data, topics }) => {
        const _topics = decodeEventLog({
          abi: EFPListRegistryABI,
          data,
          topics,
        })
        console.log('[EFPListRegistry] Decoded topics:', JSON.stringify(_topics, undefined, 2))
      })
    },
  })

  client.watchContractEvent({
    abi: EFPListRecordsABI,
    address: '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0',
    // eventName: 'OwnershipTransferred',
    onError: (error) => {
      console.log('EFPListMetadataABI error:', error)
    },
    onLogs: (logs) => {
      console.log('\n--- EFPListMetadata ---\n')
      logs.map(({ data, topics }) => {
        const _topics = decodeEventLog({
          abi: EFPListRecordsABI,
          data,
          topics,
        })
        console.log('[EFPListMetadata] Decoded topics:', JSON.stringify(_topics, undefined, 2))
      })
    },
  })

  client.watchContractEvent({
    abi: EFPListRecordsABI,
    address: '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9',
    // eventName: 'ListOperation',
    onError: (error) => {
      console.log('EFPListRecordsABI error:', error)
    },
    onLogs: (logs) => {
      console.log('\n--- EFPListRecords ---\n')
      logs.map(({ data, topics }) => {
        const _topics = decodeEventLog({
          abi: EFPListRecordsABI,
          data,
          topics,
        })
        console.log('[EFPListRecords] Decoded topics:', JSON.stringify(_topics, undefined, 2))
      })
    },
  })

  client.watchContractEvent({
    abi: EFPListMinterABI,
    address: '0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9',
    onError: (error) => {
      console.log('EFPListMinterABI error:', error)
    },
    onLogs: (logs) => {
      console.log('\n--- EFPListMinter ---\n')
      logs.map(({ data, topics }) => {
        const _topics = decodeEventLog({
          abi: EFPListMinterABI,
          data,
          topics,
        })
        console.log('[EFPListMinter] Decoded topics:', JSON.stringify(_topics, undefined, 2))
      })
    },
  })
}
