import {
  concatHex,
  numberToHex,
  pad,
  stringToHex,
  type Address,
  type Hex
} from 'viem'

/**
 * On-chain encodings for EFP, mirrored from the Solidity helpers
 * (`scripts/util/ListOpUtils.sol`, `EFPListMinter.decodeL1ListStorageLocation`).
 *
 * These are intentionally tiny and dependency-free so scenarios + tests can
 * build calldata without going through the Forge scripts.
 */

const LIST_STORAGE_LOCATION_VERSION = 0x01
const LIST_STORAGE_LOCATION_TYPE_L1 = 0x01

const LIST_OP_VERSION = 0x01
const LIST_RECORD_VERSION = 0x01
const LIST_RECORD_TYPE_ADDRESS = 0x01

export const ListOpcode = {
  ADD_RECORD: 0x01,
  REMOVE_RECORD: 0x02,
  ADD_TAG: 0x03,
  REMOVE_TAG: 0x04
} as const

function byte(value: number): Hex {
  return numberToHex(value, { size: 1 })
}

/**
 * Encodes an L1 list storage location:
 * version(1) | type(1) | chainId(32) | listRecords(20) | slot(32) = 86 bytes
 */
export function encodeListStorageLocation({
  chainId,
  listRecords,
  slot
}: {
  chainId: number | bigint
  listRecords: Address
  slot: bigint
}): Hex {
  return concatHex([
    byte(LIST_STORAGE_LOCATION_VERSION),
    byte(LIST_STORAGE_LOCATION_TYPE_L1),
    numberToHex(BigInt(chainId), { size: 32 }),
    pad(listRecords, { size: 20 }),
    numberToHex(slot, { size: 32 })
  ])
}

/** A list record pointing at an address: version(1) | type(1) | address(20). */
export function encodeAddressRecord(address: Address): Hex {
  return concatHex([byte(LIST_RECORD_VERSION), byte(LIST_RECORD_TYPE_ADDRESS), pad(address, { size: 20 })])
}

/** A raw list op: opVersion(1) | opcode(1) | data. */
export function encodeListOp({ opcode, data }: { opcode: number; data: Hex }): Hex {
  return concatHex([byte(LIST_OP_VERSION), byte(opcode), data])
}

/** Add-record op that follows `target`. */
export function encodeFollowOp(target: Address): Hex {
  return encodeListOp({ opcode: ListOpcode.ADD_RECORD, data: encodeAddressRecord(target) })
}

/** Remove-record op that unfollows `target`. */
export function encodeUnfollowOp(target: Address): Hex {
  return encodeListOp({ opcode: ListOpcode.REMOVE_RECORD, data: encodeAddressRecord(target) })
}

/** Tag op: appends a UTF-8 tag to the address record. */
export function encodeTagOp(target: Address, tag: string): Hex {
  return encodeListOp({
    opcode: ListOpcode.ADD_TAG,
    data: concatHex([encodeAddressRecord(target), stringToHex(tag)])
  })
}

/** Untag op. */
export function encodeUntagOp(target: Address, tag: string): Hex {
  return encodeListOp({
    opcode: ListOpcode.REMOVE_TAG,
    data: concatHex([encodeAddressRecord(target), stringToHex(tag)])
  })
}
