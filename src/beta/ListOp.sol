// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title ListOp
 * @notice A ListOp represents an operation to be performed on a list.
 */
struct ListOp {
    /// @notice The version byte of the list record.
    /// @dev Used for differentiating between record formats for upgradability,
    ///      ensuring backward compatibility, and identifying the record's schema.
    uint8 version;

    /// @dev Represents the operation code (opcode) for the list operation.
    ///      It's a byte-sized identifier for the type of operation to be performed.
    ///      For example, different byte values could signify add, remove, update, etc.
    uint8 code;

    /// @dev Contains the data or parameters associated with the list operation.
    ///      This is a dynamic byte array, allowing flexibility in the amount and type of
    ///      data that can be included. The structure and interpretation of this data
    ///      depend on the operation code defined in the `code` field.
    bytes data;
}
