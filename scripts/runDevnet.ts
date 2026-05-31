#!/usr/bin/env bun
import { createServer } from 'node:http'
import { parseArgs } from 'node:util'
import { getAddress } from 'viem'
import { setupDevnet } from './devnet/setup.ts'
import { isScenarioName, scenarios, type ScenarioName } from './devnet/scenarios.ts'
import { keepAlive, onShutdown, registerShutdownHandlers } from './devnet/shutdown.ts'

const t0 = Date.now()

const args = parseArgs({
  args: process.argv.slice(2),
  options: {
    'rpc-url': { type: 'string', default: process.env.DEVNET_RPC_URL },
    port: { type: 'string', default: process.env.DEVNET_PORT ?? '8545' },
    'chain-id': { type: 'string', default: process.env.DEVNET_CHAIN_ID ?? '31337' },
    host: { type: 'string', default: process.env.DEVNET_HOST ?? '127.0.0.1' },
    scenario: { type: 'string', default: process.env.DEVNET_SCENARIO ?? 'empty' },
    'save-deployments': { type: 'boolean' },
    'no-save-deployments': { type: 'boolean' },
    'block-time': { type: 'string', default: process.env.DEVNET_BLOCK_TIME ?? '1' },
    'proc-log': { type: 'boolean', default: false },
    'health-port': { type: 'string', default: process.env.DEVNET_HEALTH_PORT ?? '8000' }
  },
  strict: true
})

const scenarioName = args.values.scenario as string
if (!isScenarioName(scenarioName)) {
  console.error(`Unknown scenario "${scenarioName}". Available: ${Object.keys(scenarios).join(', ')}`)
  process.exit(1)
}

const host = args.values.host!
const healthPort = Number(args.values['health-port'])

// Node's parseArgs has no native `--no-*` negation, so resolve precedence
// explicitly: --no-save-deployments > --save-deployments > env default (on).
const saveDeployments = args.values['no-save-deployments']
  ? false
  : (args.values['save-deployments'] ?? process.env.DEVNET_SAVE_DEPLOYMENTS !== 'false')

registerShutdownHandlers()

console.log('Starting EFP devnet...')
const env = await setupDevnet({
  rpcUrl: args.values['rpc-url'],
  port: Number(args.values.port),
  chainId: Number(args.values['chain-id']),
  host,
  blockTime: Number(args.values['block-time']),
  procLog: args.values['proc-log'] ?? false,
  saveDeployments,
  quiet: !(args.values['proc-log'] ?? false)
})
onShutdown(() => env.shutdown())

console.log(`Running scenario "${scenarioName}"...`)
await scenarios[scenarioName as ScenarioName](env)

console.log()
console.log('Named accounts:')
console.table(
  Object.entries(env.accounts).map(([name, account]) => ({ Name: name, Address: account.address }))
)

console.log()
console.log('Deployments:')
console.table(
  (Object.keys(env.deployments) as Array<keyof typeof env.deployments>)
    .filter((key) => key !== 'chainId')
    .map((name) => ({ Contract: name, Address: getAddress(env.deployments[name] as string) }))
)

console.log()
console.log({
  Chain: env.chainId,
  Endpoint: `{http,ws}://${host}:${args.values.port}`,
  Attached: env.external,
  Scenario: scenarioName,
  ReadyMs: Date.now() - t0
})

const healthServer = createServer((req, res) => {
  if (req.url !== '/health' && req.url !== '/') {
    res.writeHead(404)
    res.end()
    return
  }
  res.writeHead(200, { 'Content-Type': 'text/plain' })
  res.end('healthy\n')
})
healthServer.listen(healthPort, host, () => {
  console.log(`Healthcheck listening on http://${host}:${healthPort}/health`)
})
onShutdown(
  () =>
    new Promise<void>((resolve) => {
      healthServer.close(() => resolve())
    })
)

await keepAlive()
