// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @title ListRecord
/// @notice A ListRecord is a struct that represents a list record.
struct ListRecord {
    /// @notice The version byte of the list record.
    /// @dev Used for differentiating between record formats for upgradability,
    ///      ensuring backward compatibility, and identifying the record's schema.
    uint8 version;
    /// @notice The type of the list record.
    /// @dev Represents the specific category or format of the list record.
    uint8 recordType;
    /// @notice The data associated with the list record.
    /// @dev Contains the actual content or information of the list record.
    bytes data;
}
