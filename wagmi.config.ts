import fs from 'node:fs'
import url from 'node:url'
import path from 'node:path'
import { defineConfig } from '@wagmi/cli'
import { foundry } from '@wagmi/cli/plugins'

const __dirname = path.dirname(url.fileURLToPath(import.meta.url))

/**
 * docs: https://beta.wagmi.sh
 *
 * Runs forge build then generates a single typescript file containing all ABIs
 *
 * Usage:
 *
 * ```sh
 * bun wagmi generate path/to/write/to.ts
 * ```
 */

const [, outPath] = process.argv.slice(2)

const artifacts = fs
  .readdirSync(path.join(__dirname, 'src'))
  .filter((item) => item.startsWith('EFP'))
  .map((item) => `${item}/**`)

export default defineConfig({
  out: outPath ?? path.join(__dirname, 'generated', 'abi.ts'),
  plugins: [
    foundry({
      artifacts: 'out/',
      include: artifacts,
      project: __dirname,
      forge: {
        clean: true,
        build: true,
        rebuild: true
      }
    })
  ]
})
