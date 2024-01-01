import fs from 'node:fs'
import url from 'node:url'
import path from 'node:path'
import { defineConfig, type Plugin } from '@wagmi/cli'
import { foundry, etherscan, actions, react, type FoundryConfig } from '@wagmi/cli/plugins'

const __dirname = path.dirname(url.fileURLToPath(import.meta.url))

const ENABLE_ETHERSCAN = false

/**
 * docs: https://beta.wagmi.sh
 * Runs forge build then generates a single typescript file containing all ABIs
 * Usage:
 * ```sh
 * bun wagmi generate path/to/write/to.ts
 * ```
 */

const [, outDir] = process.argv.slice(2)

export default defineConfig([
  {
    out: outDir ? path.join(outDir, 'abi.ts') : path.join(__dirname, 'generated', 'abi.ts'),
    plugins: [
      foundryPlugin({
        build: true,
        clean: true,
        rebuild: true
      }),
      etherscanPlugin()
    ]
  },
  {
    out: outDir ? path.join(outDir, 'actions.ts') : path.join(__dirname, 'generated', 'actions.ts'),
    plugins: [
      foundryPlugin(),
      actions({
        overridePackageName: 'wagmi',
        getActionName: (options) => {
          console.log(JSON.stringify(options, undefined, 2))
          return `${options.contractName}_${options.type}_${options.itemName}`
        }
      })
    ]
  },
  {
    out: outDir ? path.join(outDir, 'react.ts') : path.join(__dirname, 'generated', 'hooks.ts'),
    plugins: [
      //
      foundryPlugin(),
      react({})
    ]
  }
])

function foundryPlugin(forgeConfig?: FoundryConfig['forge']): Plugin {
  const artifacts = fs
    .readdirSync(path.join(__dirname, 'src'))
    .filter((item) => item.startsWith('EFP'))
    .map((item) => `${item}/**`)

  return foundry({
    artifacts: 'out/',
    include: artifacts,
    project: __dirname,
    forge: { build: true, clean: false, rebuild: false, ...forgeConfig }
  })
}

/**
 * Only Sepolia for now
 */
function etherscanPlugin(): Plugin {
  if (!ENABLE_ETHERSCAN) {
    return () => {}
  }
  return etherscan({
    apiKey: process.env.ETHERSCAN_API_KEY,
    chainId: 11_155_111,
    contracts: [
      {
        name: 'EFPAccountMetadata',
        address: '0x_PLACEHOLDER'
      },
      {
        name: 'EFPListManager',
        address: '0x_PLACEHOLDER'
      },
      {
        name: 'ListMetadata',
        address: '0x_PLACEHOLDER'
      },
      {
        name: 'ListRecords',
        address: '0x_PLACEHOLDER'
      },
      {
        name: 'EFPListRecords',
        address: '0x_PLACEHOLDER'
      },
      {
        name: 'EFPListRegistry',
        address: '0x_PLACEHOLDER'
      }
    ]
  })
}
