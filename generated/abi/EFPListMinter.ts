export const EFPListMinterABI = [
  {
    type: 'constructor',
    inputs: [
      {
        name: '_registryAddress',
        type: 'address',
        internalType: 'address',
      },
      {
        name: '_accountMetadataAddress',
        type: 'address',
        internalType: 'address',
      },
      {
        name: '_listRecordsL1',
        type: 'address',
        internalType: 'address',
      },
    ],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'accountMetadata',
    inputs: [],
    outputs: [
      {
        name: '',
        type: 'address',
        internalType: 'contract IEFPAccountMetadata',
      },
    ],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'listRecordsL1',
    inputs: [],
    outputs: [
      {
        name: '',
        type: 'address',
        internalType: 'contract IEFPListRecords',
      },
    ],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'mintAndSetAsDefaultList',
    inputs: [
      {
        name: 'listStorageLocation',
        type: 'bytes',
        internalType: 'bytes',
      },
    ],
    outputs: [],
    stateMutability: 'payable',
  },
  {
    type: 'function',
    name: 'mintToAndSetAsDefaultList',
    inputs: [
      {
        name: 'to',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'listStorageLocation',
        type: 'bytes',
        internalType: 'bytes',
      },
    ],
    outputs: [],
    stateMutability: 'payable',
  },
  {
    type: 'function',
    name: 'owner',
    inputs: [],
    outputs: [
      {
        name: '',
        type: 'address',
        internalType: 'address',
      },
    ],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'registry',
    inputs: [],
    outputs: [
      {
        name: '',
        type: 'address',
        internalType: 'contract IEFPListRegistry_ERC721',
      },
    ],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'renounceOwnership',
    inputs: [],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'transferOwnership',
    inputs: [
      {
        name: 'newOwner',
        type: 'address',
        internalType: 'address',
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'event',
    name: 'OwnershipTransferred',
    inputs: [
      {
        name: 'previousOwner',
        type: 'address',
        indexed: true,
        internalType: 'address',
      },
      {
        name: 'newOwner',
        type: 'address',
        indexed: true,
        internalType: 'address',
      },
    ],
    anonymous: false,
  },
] as const
