// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title ListStorageLocation
 * @notice A ListStorageLocation is a struct that represents a location of a list
 */
struct ListStorageLocation {

    /**
     * @dev The version byte allows for:
     * 1. Differentiating between record formats for upgradability.
     * 2. Ensuring backward compatibility with older versions.
     * 3. Identifying the record's schema or processing logic.
     */
    uint8 version;

    /// @dev type of list location
    uint8 locationType;

    /// @dev data for the list location
    bytes data;
}
