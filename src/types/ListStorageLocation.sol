// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title ListStorageLocation
 * @notice A ListStorageLocation is a struct that represents the storage
 *         location of a list.
 * @dev The EFP contracts don't use this struct; they only store list
 *      storage locations as `bytes` with the version, location type,
 *      and data fields tightly packed into a single `bytes` value
 *      however, this struct can be useful for offchain processing with
 *      foundry or other Solidity tooling
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
    /// @notice The data associated with the list storage location.
    /// @dev Contains the actual content or information of the list storage
    ///location.
    bytes data;
}
