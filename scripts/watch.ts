import { parseAbiItem } from 'viem/utils'
import { client } from './client'

const unwatch = client.watchEvent({
  address: '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512',
  event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'),
  onLogs: (logs) => console.log(logs),
})
