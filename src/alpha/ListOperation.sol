// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title ListOperation
 * @notice Represents an operation to be performed on a list.
 */
struct ListOperation {
    uint8 operationType;
    bytes data;
}
