export const EFPAccountMetadataABI = [
  {
    type: 'function',
    name: 'addProxy',
    inputs: [
      {
        name: 'proxy',
        type: 'address',
        internalType: 'address',
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'getValue',
    inputs: [
      {
        name: 'addr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'key',
        type: 'string',
        internalType: 'string',
      },
    ],
    outputs: [
      {
        name: '',
        type: 'bytes',
        internalType: 'bytes',
      },
    ],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'getValues',
    inputs: [
      {
        name: 'addr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'keys',
        type: 'string[]',
        internalType: 'string[]',
      },
    ],
    outputs: [
      {
        name: '',
        type: 'bytes[]',
        internalType: 'bytes[]',
      },
    ],
    stateMutability: 'view',
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
    name: 'removeProxy',
    inputs: [
      {
        name: 'proxy',
        type: 'address',
        internalType: 'address',
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
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
    name: 'setValue',
    inputs: [
      {
        name: 'key',
        type: 'string',
        internalType: 'string',
      },
      {
        name: 'value',
        type: 'bytes',
        internalType: 'bytes',
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'setValueForAddress',
    inputs: [
      {
        name: 'addr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'key',
        type: 'string',
        internalType: 'string',
      },
      {
        name: 'value',
        type: 'bytes',
        internalType: 'bytes',
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'setValues',
    inputs: [
      {
        name: 'records',
        type: 'tuple[]',
        internalType: 'struct IEFPAccountMetadata.KeyValue[]',
        components: [
          {
            name: 'key',
            type: 'string',
            internalType: 'string',
          },
          {
            name: 'value',
            type: 'bytes',
            internalType: 'bytes',
          },
        ],
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'setValuesForAddress',
    inputs: [
      {
        name: 'addr',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'records',
        type: 'tuple[]',
        internalType: 'struct IEFPAccountMetadata.KeyValue[]',
        components: [
          {
            name: 'key',
            type: 'string',
            internalType: 'string',
          },
          {
            name: 'value',
            type: 'bytes',
            internalType: 'bytes',
          },
        ],
      },
    ],
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
  {
    type: 'event',
    name: 'ProxyAdded',
    inputs: [
      {
        name: 'proxy',
        type: 'address',
        indexed: false,
        internalType: 'address',
      },
    ],
    anonymous: false,
  },
  {
    type: 'event',
    name: 'ProxyRemoved',
    inputs: [
      {
        name: 'proxy',
        type: 'address',
        indexed: false,
        internalType: 'address',
      },
    ],
    anonymous: false,
  },
  {
    type: 'event',
    name: 'ValueSet',
    inputs: [
      {
        name: 'addr',
        type: 'address',
        indexed: true,
        internalType: 'address',
      },
      {
        name: 'key',
        type: 'string',
        indexed: false,
        internalType: 'string',
      },
      {
        name: 'value',
        type: 'bytes',
        indexed: false,
        internalType: 'bytes',
      },
    ],
    anonymous: false,
  },
] as const
