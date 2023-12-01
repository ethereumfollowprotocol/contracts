import { foundry, mainnet } from 'viem/chains'
import { privateKeyToAccount } from 'viem/accounts'
import {
  http,
  createTestClient,
  publicActions,
  walletActions,
  isHex,
  type PrivateKeyAccount,
  createPublicClient,
} from 'viem'
import { EFPListMetadataABI } from 'scripts/abi/EFPListMetadata'
import { EFPAccountMetadataABI } from './abi/EFPAccountMetadata'
import { EFPListsABI } from 'scripts/abi/EFPLists'

const anvilAccountPrivateKey = process.env.ANVIL_ACCOUNT_PRIVATE_KEY

if (!isHex(anvilAccountPrivateKey)) {
  throw new Error('ANVIL_ACCOUNT_PRIVATE_KEY env variable is not set. Check README.md')
}

export const account: PrivateKeyAccount = privateKeyToAccount(anvilAccountPrivateKey)

export const client = createTestClient({
  chain: mainnet,
  mode: 'anvil',
  transport: http('http://0.0.0.0:8545'),
  account,
})
  .extend(publicActions)
  .extend(walletActions)

const publicClient = createPublicClient({
  chain: mainnet,
  transport: http(),
})

// client.watchContractEvent({
//   abi: [] as any[],
//   address: '0x0000',
//   args: [],
//   onLogs: (log) => {

//   },
// })

// EFPAccountMetadata
// client
//   .readContract({
//     abi: EFPAccountMetadataABI,
//     functionName: 'getValue',
//     address: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
//     args: ['0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266', 'efp.list.primary'],
//   })
//   .then(console.log)
// client
//   .readContract({
//     abi: EFPListMetadataABI,
//     functionName: 'getValue',
//     address: '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0',
//     args: [0n, 'efp.list.location'],
//   })
  // .then(console.log)
