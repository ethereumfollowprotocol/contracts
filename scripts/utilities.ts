import type { Address } from 'viem'
import { client } from './clients.ts'

export async function getTransactionReceipt(hash: Address) {
  return await client.getTransactionReceipt({ hash })
}
