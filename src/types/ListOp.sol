// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title ListOp
 * @notice A ListOp represents an operation to be performed on a list.
 * @dev The EFP contracts don't use this struct; they only store list ops
 *      as `bytes` with the version, opcode, and data fields tightly packed
 *      into a single `bytes` value. However, this struct can be useful for
 *      offchain processing with foundry or other Solidity tooling
 */
struct ListOp {
    /// @notice The version byte of the list operation.
    /// @dev Used for differentiating between record formats for upgradability,
    ///      ensuring backward compatibility, and identifying the record's
    ///      schema.
    uint8 version;
    /// @dev Represents the operation code (opcode) for the list operation.
    ///      It's a byte-sized identifier for the type of list operation to be
    ///      performed.
    uint8 opcode;
    /// @dev Contains the data or parameters associated with the list
    ///      operation. This is a dynamic byte array, allowing flexibility in
    //       the size and type of data that can be included. The structure and
    ///      interpretation of this data depend on the operation code defined
    ///      in the `opcode` field.
    bytes data;
}
