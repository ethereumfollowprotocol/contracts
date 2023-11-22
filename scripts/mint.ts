#!/usr/bin/env bun
import type { Address } from 'viem'
import { account, client } from './client.ts'

const listRegistryAbi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: 'address',
        name: 'owner',
        type: 'address',
      },
      {
        indexed: true,
        internalType: 'address',
        name: 'operator',
        type: 'address',
      },
      {
        indexed: false,
        internalType: 'bool',
        name: 'approved',
        type: 'bool',
      },
    ],
    name: 'ApprovalForAll',
    type: 'event',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'to',
        type: 'address',
      },
      {
        internalType: 'uint256',
        name: 'tokenId',
        type: 'uint256',
      },
    ],
    name: 'approve',
    outputs: [],
    stateMutability: 'payable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'tokenId',
        type: 'uint256',
      },
    ],
    name: 'getListStorageLocation',
    outputs: [
      {
        components: [
          {
            internalType: 'uint8',
            name: 'version',
            type: 'uint8',
          },
          {
            internalType: 'uint8',
            name: 'locationType',
            type: 'uint8',
          },
          {
            internalType: 'bytes',
            name: 'data',
            type: 'bytes',
          },
        ],
        internalType: 'struct ListStorageLocation',
        name: '',
        type: 'tuple',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'owner',
        type: 'address',
      },
      {
        internalType: 'address',
        name: 'operator',
        type: 'address',
      },
    ],
    name: 'isApprovedForAll',
    outputs: [
      {
        internalType: 'bool',
        name: '',
        type: 'bool',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'mint',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'to',
        type: 'address',
      },
    ],
    name: 'mintTo',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'operator',
        type: 'address',
      },
      {
        internalType: 'bool',
        name: 'approved',
        type: 'bool',
      },
    ],
    name: 'setApprovalForAll',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'tokenId',
        type: 'uint256',
      },
      {
        components: [
          {
            internalType: 'uint8',
            name: 'version',
            type: 'uint8',
          },
          {
            internalType: 'uint8',
            name: 'locationType',
            type: 'uint8',
          },
          {
            internalType: 'bytes',
            name: 'data',
            type: 'bytes',
          },
        ],
        internalType: 'struct ListStorageLocation',
        name: 'listStorageLocation',
        type: 'tuple',
      },
    ],
    name: 'setListStorageLocation',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'tokenId',
        type: 'uint256',
      },
      {
        internalType: 'address',
        name: 'userAddress',
        type: 'address',
      },
    ],
    name: 'setUser',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'tokenId',
        type: 'uint256',
      },
    ],
    name: 'tokenURI',
    outputs: [
      {
        internalType: 'string',
        name: '',
        type: 'string',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
] as const

async function mint(contractAddress: Address) {
  const setApprovalHash = await client.writeContract({
    abi: listRegistryAbi,
    functionName: 'setApprovalForAll',
    account: account.address,
    address: contractAddress,
    args: [account.address, true],
  })

  console.log('setApprovalForAll hash:', setApprovalHash)

  const mintHash = await client.writeContract({
    abi: listRegistryAbi,
    functionName: 'mint',
    account: account.address,
    address: contractAddress,
  })

  console.log('mint hash:', mintHash)
}

mint('0x9A86494Ba45eE1f9EEed9cFC0894f6C5d13a1F0b').catch((error) => {
  console.error(JSON.stringify(error, undefined, 2))
  process.exit(1)
})
