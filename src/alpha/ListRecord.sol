// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title ListRecord
 * @notice A ListRecord is a struct that represents a list record
 */
struct ListRecord {

    /**
     * @dev The version byte allows for:
     * 1. Differentiating between record formats for upgradability.
     * 2. Ensuring backward compatibility with older versions.
     * 3. Identifying the record's schema or processing logic.
     */
    uint8 version;

    /// @dev type of list record
    uint8 recordType;

    /// @dev data for the list record
    bytes data;
}
