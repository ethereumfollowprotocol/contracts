# List Registry

The list registry is an NFT contract `EFPListRegistry` on Ethereum where the NFT represents ownership of an EFP List.

## Minting an EFP List

Minting an EFP List is free and unrestricted.

TOOD: confirm non-rentrancy

Any address can mint an EFP List NFT but only one EFP List can be minted per transaction.

To mint an EFP List, simply call the `mint` function on the `EFPListRegistry` contract
with a provided list storage location (TODO link docs).

```solidity
// mint an EFP List
efpListRegistry.mint(<list_storage_location>);
```

To mint to a specific address, call the `mintTo` function on the `EFPListRegistry` contract.

```solidity
// mint an EFP List to a specific address
efpListRegistry.mintTo(<address>, <list_storage_location>);
```

# Lists

Lists are stored in a contract `EFPListRecords` which may be deployed on Ethereum L1 or a supported L2 chain.

A list is comprised of list records, which can be associated with a list of strings called "tags".

There are four operations supported on lists:

| Code | Operation     |
| ---- | ------------- |
| 1    | Add record    |
| 2    | Remove record |
| 3    | Tag record    |
| 4    | Untag record  |

Other operations may be added in the future.

## List Record

A `ListRecord` is a fundamental data structure representing a record in a list. Each `ListRecord` consists of the following components:

- `version`: A `uint8` representing the version of the `ListRecord`. This is used to ensure compatibility and facilitate future upgrades.
- `recordType`: A `uint8` indicating the type of record. This serves as an identifier for the kind of data the record holds.
- `data`: A `bytes` array containing the actual data of the record. The structure of this data depends on the `recordType`.

Onchain, list records are packed into byte arrays with the version and record type prepended:

```
+------------------+---------------------+------------------------+
|                  |                     |                        |
| version (1 byte) | recordType (1 byte) | data (variable length) |
|                  |                     |                        |
+------------------+---------------------+------------------------+
```

Off-chain, use a dedicated type for processing list records:
```typescript
// TypeScript
type ListRecord = {
    version: number; // 0-255
    recordType: number; // 0-255
    data: Uint8Array;
}
```
```rust
// Rust
struct ListRecord {
    version: u8,
    record_type: u8,
    data: Vec<u8>,
}
```
```python
# Python
class ListRecord:
    version: int # 0-255
    record_type: int # 0-255
    data: bytes
```
```go
// Go
type ListRecord struct {
    Version    uint8
    RecordType uint8
    Data       []byte
}
```
```solidity
// Solidity
//
// the EFP contracts don't use this struct; they only store list ops as `bytes`
// but this struct can be useful for offchain processing with foundry or other
// Solidity tooling
struct ListRecord {
    uint8 version;
    uint8 recordType;
    bytes data;
}
```

### Record Types

There are only two record types defined at this time:

| Type   | Description           | Data             | Length |
| ------ | --------------------- | ---------------- | ------ |
| 0      | Reserved              | N/A              | N/A    |
| 1      | EFP List Subscription | 32-byte token id | 32     |
| 2-9    | Reserved              | N/A              | N/A    |
| 10     | Address               | 20-byte address  | 20     |
| 11-255 | Reserved              | N/A              | N/A    |

Record types 0, 2-9, and 11-255 are reserved for future use.

To illustrate the design, however, consider hypothetical list record types:

<!-- - a subscription to another EFP List, where the `data` field would contain the 32-byte token ID of the corresponding EFP NFT. -->
- an encrypted list record, where the `data` field would contain a list record encrypted with the public key of the list owner/manager/user (for privacy).
- an ERC-721 NFT token, where the `data` field would contain the 20-byte address of the ERC-721 contract, and the 32-byte token ID.
- an ERC-1155 token, where the `data` field would contain the 20-byte address of the ERC-1155 contract, the 32-byte token ID (exclude token amount).
- an ENS name, where the `data` field would contain the normalized string of the ENS name.
- a DID record, where the `data` field would contain the DID string.
- a DNS name, where the `data` field would contain the normalized string of the DNS name.
- an RSS feed, where the `data` field would contain the string URL of the RSS feed.
- an Atom feed, where the `data` field would contain the string URL of the Atom feed.
- a git repository URL, where the `data` field would contain the git remote URL string.
- an IP address, where the `data` field would contain the IP address string.
- an email address, where the `data` field would contain the email address string.
- a torrent magnet link, where the `data` field would contain the magnet link string.
- a custom record, where the `data` field would contain arbitrary or custom data.

Clients may support some or all of these record types depending on use case (once more than one record type is defined).

### Decoding

Managers have permissions to upload arbitrary list record data, so clients should be prepared to handle unexpected data.

When decoding a `ListRecord`, the `version` and `recordType` fields should be checked to ensure compatibility.

The length of the `data` field should be checked to ensure it is the expected length for the given `recordType`.

If the length of the `data` field is unexpected, the `ListRecord` should generally be ignored and not processed.

## Tag

A `Tag` is a string associated with a `ListRecord` in a list. A `ListRecord` can have multiple tags associated with it. A `Tag` is represented as a string.

### Normalization

Tags are normalized by converting them to lowercase and removing leading and trailing whitespace.

Tags should be normalized before they are encoded into a `ListOp`.

## ListOp

A `ListOp` is a structure used to encapsulate an operation to be performed on a list. It includes the following fields:

- `version`: A `uint8` representing the version of the `ListOp`. This is used to ensure compatibility and facilitate future upgrades.
- `opcode`: A `uint8` indicating the operation code. This defines the action to be taken using the `ListOp`.
- `data`: A `bytes` array which holds the operation-specific data. For instance, if the operation involves adding a `ListRecord`, this field would contain the encoded `ListRecord`.

```solidity
struct ListOp {
    uint8 version;
    uint8 opcode;
    bytes data;
}
```

### Operation Codes

There are four operations defined at this time:

| Code | Operation     | data                                 |
| ---- | ------------- | ------------------------------------ |
| 1    | Add record    | Encoded `ListRecord`                 |
| 2    | Remove record | Encoded `ListRecord`                 |
| 3    | Tag record    | Encoded `ListRecord` followed by tag |
| 4    | Untag record  | Encoded `ListRecord` followed by tag |

## Encoding

The encoding of a `ListOp` is designed to be flexible, accommodating various types of operations and their corresponding data structures. The encoded form looks as follows:

| Byte(s) | Description                     |
| ------- | ------------------------------- |
| 0       | `ListOp` version (1 byte)       |
| 1       | Operation code (1 byte)         |
| 2 - N   | Encoded operation-specific data |

The `2 - N` byte range is variable and depends on the operation being performed.

### Example - Add Record

The following is an example of an encoded `ListOp` for adding a `ListRecord` of type 1 (raw address) to a list:

| Byte(s) | Description                   | Value                                      |
| ------- | ----------------------------- | ------------------------------------------ |
| 0       | `ListOp` version (1 byte)     | 0x01                                       |
| 1       | Operation code (1 byte)       | 0x01                                       |
| 2       | `ListRecord` version (1 byte) | 0x01                                       |
| 3       | `ListRecord` type (1 byte)    | 0x01                                       |
| 4 - 23  | `ListRecord` data (20 bytes)  | 0x00000000000000000000000000000000DeaDBeef |

### Example - Remove Record

The following is an example of an encoded `ListOp` for removing a `ListRecord` of type 1 (raw address) from a list:

| Byte(s) | Description                   | Value                                      |
| ------- | ----------------------------- | ------------------------------------------ |
| 0       | `ListOp` version (1 byte)     | 0x01                                       |
| 1       | Operation code (1 byte)       | 0x02                                       |
| 2       | `ListRecord` version (1 byte) | 0x01                                       |
| 3       | `ListRecord` type (1 byte)    | 0x01                                       |
| 4 - 23  | `ListRecord` data (20 bytes)  | 0x00000000000000000000000000000000DeaDBeef |

### Example - Tag Record

The following is an example of an encoded `ListOp` for tagging a `ListRecord` of type 1 (raw address) in a list:

| Byte(s) | Description                   | Value                                      |
| ------- | ----------------------------- | ------------------------------------------ |
| 0       | `ListOp` version (1 byte)     | 0x01                                       |
| 1       | Operation code (1 byte)       | 0x03                                       |
| 2       | `ListRecord` version (1 byte) | 0x01                                       |
| 3       | `ListRecord` type (1 byte)    | 0x01                                       |
| 4 - 23  | `ListRecord` data (20 bytes)  | 0x00000000000000000000000000000000DeaDBeef |
| 24 - N  | Tag (variable) (UTF-8)        | 0x746167 ("tag")                           |

The tag should be encoded as UTF-8.

### Example - Untag Record

The following is an example of an encoded `ListOp` for untagging a `ListRecord` of type 1 (raw address) in a list:

| Byte(s) | Description                   | Value                                      |
| ------- | ----------------------------- | ------------------------------------------ |
| 0       | `ListOp` version (1 byte)     | 0x01                                       |
| 1       | Operation code (1 byte)       | 0x04                                       |
| 2       | `ListRecord` version (1 byte) | 0x01                                       |
| 3       | `ListRecord` type (1 byte)    | 0x01                                       |
| 4 - 23  | `ListRecord` data (20 bytes)  | 0x00000000000000000000000000000000DeaDBeef |
| 24 - N  | Tag (variable) (UTF-8)        | 0x746167 ("tag")                           |

The tag should be encoded as UTF-8.

## Social Graph

The social graph is the full set of lists and their associated records and tags.

To construct the social graph, it is sufficient to iterate through all lists and apply the operations in order:

```
for each list in lists:
    for each op in list:
        apply op to social graph
```

### Via Logs

The contract defines a `ListOp` event as:

```solidity
event ListOp(uint indexed nonce, bytes op);
```

So, the social graph can be constructed by iterating through the `ListOp` events emitted by the EFP NFT contract.

### Via Contract Calls

The contract defines four read functions:

- `getListOpCount`: Returns the number of operations in a list.
- `getListOp`: Returns a single operation in a list.
- `getListOpsInRange`: Returns a range of operations in a list.
- `getAllListOps`: Returns all operations in a list.

If you are using a node without gas limits, you can use `getAllListOps` to retrieve all operations in a list. Otherwise, you will need to use `getListOpCount` and `getListOpsInRange` to retrieve the operations in batches.

### Social Graph implementation

A rough implementation of a Social Graph is defined below

```TypeScript
type TokenId = number;

type ListRecord {
    version: number;
    recordType: number;
    data: bytes;
}

type Tag = string;

class LinkedListNode {
    value: ListRecord;
    next: LinkedListNode | null;
    prev: LinkedListNode | null;

    constructor(value: ListRecord) {
        this.value = value;
        this.next = null;
        this.prev = null;
    }
}

class LinkedList {
    head: LinkedListNode | null;
    tail: LinkedListNode | null;

    constructor() {
        this.head = null;
        this.tail = null;
    }

    // O(1) time
    add(record: ListRecord) {
        const newNode = new LinkedListNode(record);
        if (!this.head) {
            this.head = newNode;
            this.tail = newNode;
        } else {
            if (this.tail) {
                this.tail.next = newNode;
                newNode.prev = this.tail;
                this.tail = newNode;
            }
        }
        return newNode; // Return the node for external reference
    }

    // O(1) time
    remove(node: LinkedListNode) {
        if (node.prev) {
            node.prev.next = node.next;
        } else {
            this.head = node.next;
        }
        if (node.next) {
            node.next.prev = node.prev;
        } else {
            this.tail = node.prev;
        }
    }
}

// Social Graph supports:
// O(1) add/remove records via doubly-linked list to maintain order
// O(1) add/remove tags via set
// O(n) get records since we need to iterate through the linked list
// O(1) get tags since we use a set
//
// other tradeoffs are possible but this is a simple implementation shown as an example
class SocialGraph {
    private listRecords: Map<TokenId, LinkedList>;
    private nodeMap: Map<ListRecord, LinkedListNode>; // To quickly find the node for a given record
    private tags: Map<TokenId, Map<LinkedListNode, Set<Tag>>>;

    constructor() {
        this.listRecords = new Map();
        this.tags = new Map();
        this.nodeMap = new Map();
    }

    addRecord(listId: TokenId, record: ListRecord): void {
        if (!this.listRecords.has(listId)) {
            this.listRecords.set(listId, new LinkedList());
        }
        const node = this.listRecords.get(listId).add(record);
        this.nodeMap.set(record, node);
    }

    removeRecord(listId: TokenId, record: ListRecord): void {
        if (this.listRecords.has(listId) && this.nodeMap.has(record)) {
            const node = this.nodeMap.get(record);
            this.listRecords.get(listId).remove(node);
            this.nodeMap.delete(record);
        }
    }

    tagRecord(listId: TokenId, record: ListRecord, tag: Tag): void {
        if (!this.tags.has(listId)) {
            this.tags.set(listId, new Map());
        }
        const node = this.nodeMap.get(record);
        if (!this.tags.get(listId).has(node)) {
            this.tags.get(listId).set(node, new Set<Tag>());
        }
        this.tags.get(listId).get(node).add(tag);
    }

    untagRecord(listId: TokenId, record: ListRecord, tag: Tag): void {
        const node = this.nodeMap.get(record);
        if (this.tags.has(listId) && this.tags.get(listId).has(node)) {
            this.tags.get(listId).get(node).delete(tag);
        }
    }

    // read-only functions

    // O(n) time
    getRecords(listId: TokenId): ListRecord[] {
        const records: ListRecord[] = [];
        if (this.listRecords.has(listId)) {
            let node = this.listRecords.get(listId).head;
            while (node) {
                records.push(node.value);
                node = node.next;
            }
        }
        return records;
    }

    // O(1) time
    getTags(listId: TokenId, record: ListRecord): Set<Tag> {
        const node = this.nodeMap.get(record);
        if (this.tags.has(listId) && this.tags.get(listId).has(node)) {
            return this.tags.get(listId).get(node);
        }
        return new Set<Tag>();
    }
}
```

# EFP Account Metadata

The `EFPAccountMetdata` contract allows any account (address) to store any EFP-related data specific to their account.

Data is stored by `string` key and `bytes` value, for each account.

This allows for the storage of account-specific EFP configuration or preference data.

## primary-list

The `primary-list` key is used to store the primary EFP List for an account.

The primary EFP List is represented as a 32-byte token id.

| Byte(s) | Description         | Value                                                              |
| ------- | ------------------- | ------------------------------------------------------------------ |
| 0-31    | Token ID (32 bytes) | 0x0000000000000000000000000000000000000000000000000000000000000001 |

with example code shown below:

```solidity
// set the primary EFP List for the caller's address
efpAccountMetadata.setValue("primary-list", abi.encodePacked(tokenId));
```

By reading the `primary-list` key for a given address, a client can determine the primary EFP List for that address.

```solidity
address addr = <address>
uint primaryEfpListTokenId = abi.decode(efpAccountMetadata.getValue(addr, "primary-list"), (uint));

// validate: primary EFP List must exist
require(primaryEfpListTokenId < efpListRegistry.totalSupply());

// validate the user for this EFP List is the caller
address user = abi.decode(efpListMetadata.getValue(primaryEfpListTokenId, "efp.list.user"), (address));
require(user == addr);
```

## Future

This pattern can be extended to support other account-specific metadata.

# EFP List Metadata

The `EFPListMetadata` contract allows any EFP List (represented as a token id) to store key-value data.

Only the owner of the EFP List NFT can set the metadata for a given token id.

Data is stored as `string` key and `bytes` value, for each EFP List (token id).

This allows EFP List NFT owners to store list-specific configuration or preference data.

## efp.list.location

The `efp.list.location` key is used to store the storage location of an EFP List.

The list location struct looks like:

```solidity
struct ListStorageLocation {
    uint8 version;
    uint8 locationType;
    bytes data;
}
```

### Location Type 1: L1 Address + Nonce

For an EFP List stored on L1, it is sufficient to specify the address of the EFP List contract and the corresponding nonce to retrieve the list data.

This can be encoded in a `bytes` array as follows:

| Byte(s) | Description                   | Value                                                              |
| ------- | ----------------------------- | ------------------------------------------------------------------ |
| 0       | `ListStorageLocation` version | 0x01                                                               |
| 1       | `ListStorageLocation` type    | 0x01                                                               |
| 2 - 21  | L1 address (20 bytes)         | 0x00000000000000000000000000000000DeaDBeef                         |
| 22 - 53 | Nonce (32 bytes)              | 0x0000000000000000000000000000000000000000000000000000000000000001 |

with example code shown below:

```solidity
bytes1 version = 0x01;
bytes1 listLocationType = 0x01;
address addr = <L1 address>;
uint256 nonce = <nonce>;

// set the list location for the EFP List
efpListMetadata.setValue(tokenId, "efp.list.location", abi.encodePacked(version, listLocationType, addr, nonce));
```

### Location Type 2: L2 Chain ID + Address + Nonce

For an EFP List stored on L2, it is sufficient to specify the chain ID, address of the EFP List contract, and the corresponding nonce to retrieve the list data.

This can be encoded in a `bytes` array as follows:

| Byte(s) | Description                   | Value                                                              |
| ------- | ----------------------------- | ------------------------------------------------------------------ |
| 0       | `ListStorageLocation` version | 0x01                                                               |
| 1       | `ListStorageLocation` type    | 0x02                                                               |
| 2 - 33  | L2 chain ID (32 bytes)        | 0x000000000000000000000000000000000000000000000000000000000000000a |
| 34 - 53 | L2 address (20 bytes)         | 0x00000000000000000000000000000000DeaDBeef                         |
| 54 - 85 | Nonce (32 bytes)              | 0x0000000000000000000000000000000000000000000000000000000000000001 |

with example code shown below:

```solidity
bytes1 version = 0x01;
bytes1 listLocationType = 0x02;
uint256 chainId = <L2 chain ID>;
address addr = <L2 address>;
uint256 nonce = <nonce>;

// set the list location for the EFP List
efpListMetadata.setValue(tokenId, "efp.list.location", abi.encodePacked(version, listLocationType, chainId, addr, nonce));
```

### Determining List Location from Metadata

By reading the `efp.list.location` key for a given EFP List, a client can determine the location of the list data, which can be used to retrieve the list data from L1 or L2.

```solidity
bytes memory listLocation = efpListMetadata.getValue(tokenId, "efp.list.location");

require(listLocation[0] == 0x01, "unsupported version");

if (listLocation[1] == 0x01) {
    // [version, listLocationType, address, nonce]
    (bytes1 version, bytes1 listLocationType, address addr, uint256 nonce) = abi.decode(listLocation, (bytes1, bytes1, address, uint256));
} else if (listLocationType == 0x02) {
    // [version, listLocationType, chainId, address, nonce]
    (bytes1 version, bytes1 listLocationType, uint256 chainId, address addr, uint256 nonce) = abi.decode(listLocation, (bytes1, bytes1, uint256, address, uint256));
} else {
    revert("Unsupported list location type");
}
```

## efp.list.user

The `efp.list.user` key is used to store the user associated with an EFP List.

The user is represented as a 20-byte address.

| Byte(s) | Description        | Value                                      |
| ------- | ------------------ | ------------------------------------------ |
| 0-19    | Address (20 bytes) | 0x00000000000000000000000000000000DeaDBeef |

with example code shown below:

```solidity
// set the user for the EFP List
efpListMetadata.setValue(tokenId, "efp.list.user", abi.encodePacked(user));
```

By reading the `efp.list.user` key for a given EFP List, a client can determine the user associated with that list.

```solidity
address user = abi.decode(efpListMetadata.getValue(tokenId, "efp.list.user"), (address));
```

## Future

This pattern can be extended to support other list-specific metadata such as a name or description.
