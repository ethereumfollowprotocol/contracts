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
        name: '_listMetadataAddress',
        type: 'address',
        internalType: 'address',
      },
      {
        name: '_listsAddressL1',
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
    name: 'listMetadata',
    inputs: [],
    outputs: [
      {
        name: '',
        type: 'address',
        internalType: 'contract IEFPListMetadata',
      },
    ],
    stateMutability: 'view',
  },
  {
    type: 'function',
    name: 'listsAddressL1',
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
    name: 'mintToWithListLocationOnL1AndSetAsDefaultList',
    inputs: [
      {
        name: 'to',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'nonceL1',
        type: 'uint256',
        internalType: 'uint256',
      },
    ],
    outputs: [],
    stateMutability: 'payable',
  },
  {
    type: 'function',
    name: 'mintToWithListLocationOnL2AndSetAsDefaultList',
    inputs: [
      {
        name: 'to',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'chainId',
        type: 'uint256',
        internalType: 'uint256',
      },
      {
        name: 'addressL2',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'nonceL2',
        type: 'uint256',
        internalType: 'uint256',
      },
    ],
    outputs: [],
    stateMutability: 'payable',
  },
  {
    type: 'function',
    name: 'mintWithListLocationOnL1AndSetAsDefaultList',
    inputs: [
      {
        name: 'nonceL1',
        type: 'uint256',
        internalType: 'uint256',
      },
    ],
    outputs: [],
    stateMutability: 'payable',
  },
  {
    type: 'function',
    name: 'mintWithListLocationOnL2AndSetAsDefaultList',
    inputs: [
      {
        name: 'chainId',
        type: 'uint256',
        internalType: 'uint256',
      },
      {
        name: 'addressL2',
        type: 'address',
        internalType: 'address',
      },
      {
        name: 'nonceL2',
        type: 'uint256',
        internalType: 'uint256',
      },
    ],
    outputs: [],
    stateMutability: 'payable',
  },
  {
    type: 'function',
    name: 'registry',
    inputs: [],
    outputs: [
      {
        name: '',
        type: 'address',
        internalType: 'contract IEFPListRegistry_',
      },
    ],
    stateMutability: 'view',
  },
] as const
