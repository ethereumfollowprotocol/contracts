export const DeplpoyerABI = [
  {
    type: 'function',
    name: 'deployAll',
    inputs: [],
    outputs: [
      {
        name: '',
        type: 'tuple',
        internalType: 'struct Contracts',
        components: [
          {
            name: 'accountMetadata',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'listRegistry',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'listMetadata',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'lists',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'listMinter',
            type: 'address',
            internalType: 'address',
          },
        ],
      },
    ],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'initContracts',
    inputs: [
      {
        name: 'contracts',
        type: 'tuple',
        internalType: 'struct Contracts',
        components: [
          {
            name: 'accountMetadata',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'listRegistry',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'listMetadata',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'lists',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'listMinter',
            type: 'address',
            internalType: 'address',
          },
        ],
      },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'loadAll',
    inputs: [],
    outputs: [
      {
        name: '',
        type: 'tuple',
        internalType: 'struct Contracts',
        components: [
          {
            name: 'accountMetadata',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'listRegistry',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'listMetadata',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'lists',
            type: 'address',
            internalType: 'address',
          },
          {
            name: 'listMinter',
            type: 'address',
            internalType: 'address',
          },
        ],
      },
    ],
    stateMutability: 'view',
  },
] as const
