# beta-contracts
Core smart contracts of Ethereum Follow Protocol Beta

## Development

### Dependencies
[Install Foundry](https://book.getfoundry.sh/getting-started/installation)

### Build
To build, run
```bash
forge build
```

Build artifacts are stored in `out/`.

### Test
To build and test, run
```
forge test
```


### Deploy contracts locally

(1) Start `anvil`

```bash
anvil --host 0.0.0.0
```
This will log accounts with private keys:
```bash
# ...

Available Accounts
==================

(0) "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" (10000.000000000000000000 ETH)
# ...

Private Keys
==================

(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
# ...
```
(2) Copy the private key above (`0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`) and store it in `.env` as `ANVIL_ACCOUNT_PRIVATE_KEY`:

```bash
# .env
ANVIL_ACCOUNT_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

(3) Run the deploy script:

```bash
bun deploy:anvil
```

(4) Now check the generated file in `./out/anvil-deployed-contracts.json` for the deployed contract addresses:

```jsonc
// out/anvil-deployed-contracts.json
[
  {
    "contractName": "ListRegistry.sol",
    "transactionHash": "0xba6196d74e9a126be1373609624fc8e3243a82ce8e76f2923c80e9424e1f7ce4",
    "contractAddress": "0xa51c1fc2f0d1a1b8494ed1fe312d7c3a78ed91c0"
  },
  {
    "contractName": "IListRegistry.sol",
    "transactionHash": "0x0bf14b3eedf38130c2b981083b928108176e5aad85c8da09199b507f76c76e1e",
    "contractAddress": "0x0dcd1bf9a1b36ce34237eeafef220932846bcd82"
  },
  {
    "contractName": "Lists.sol",
    "transactionHash": "0x88b69e6992c05a4d44a7eb6dcc340e670b6b01b24fe578cf70613077fa521ce1",
    "contractAddress": "0x9a676e781a523b5d0c0e43731313a708cb607508"
  }
]
```
