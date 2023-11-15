// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title ListOp
 * @notice Represents an operation to be performed on a list.
 */
struct ListOp {
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
