# Lists

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

```solidity
struct ListRecord {
    uint8 version;
    uint8 recordType;
    bytes data;
}
```

### Record Types

There is only one record type defined at this time:

| Type | Description | Data            |
| ---- | ----------- | --------------- |
| 1    | Raw address | 20-byte address |

To illustrate the design, however, consider a few hypothetical list record types:

- a subscription to another EFP List, where the `data` field would contain the 32-byte token ID of the corresponding EFP NFT.
- an ERC-721 NFT token, where the `data` field would contain the 20-byte address of the ERC-721 contract, and the 32-byte token ID.
- an ERC-1155 token, where the `data` field would contain the 20-byte address of the ERC-1155 contract, the 32-byte token ID, and the 32-byte token amount.
- an ENS name, where the `data` field would contain the 32-byte hash of the ENS name OR possibly the normalized string of the ENS name.

## Tag

A `Tag` is a string associated with a `ListRecord` in a list. A `ListRecord` can have multiple tags associated with it. A `Tag` is represented as a string.

### Normalization

Tags are normalized by converting them to lowercase and removing leading and trailing whitespace.

Tags should be normalized before they are encoded into a `ListOp`.

## ListOp

A `ListOp` is a structure used to encapsulate an operation to be performed on a list. It includes the following fields:

- `version`: A `uint8` representing the version of the `ListOp`. This is used to ensure compatibility and facilitate future upgrades.
- `code`: A `uint8` indicating the operation code. This defines the action to be taken using the `ListOp`.
- `data`: A `bytes` array which holds the operation-specific data. For instance, if the operation involves adding a `ListRecord`, this field would contain the encoded `ListRecord`.

```solidity
struct ListOp {
    uint8 version;
    uint8 code;
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
| 24 - N  | Tag (variable)                | 0x746167 ("tag")                           |

### Example - Untag Record

The following is an example of an encoded `ListOp` for untagging a `ListRecord` of type 1 (raw address) in a list:

| Byte(s) | Description                   | Value                                      |
| ------- | ----------------------------- | ------------------------------------------ |
| 0       | `ListOp` version (1 byte)     | 0x01                                       |
| 1       | Operation code (1 byte)       | 0x04                                       |
| 2       | `ListRecord` version (1 byte) | 0x01                                       |
| 3       | `ListRecord` type (1 byte)    | 0x01                                       |
| 4 - 23  | `ListRecord` data (20 bytes)  | 0x00000000000000000000000000000000DeaDBeef |
| 24 - N  | Tag (variable)                | 0x746167 ("tag")                           |
