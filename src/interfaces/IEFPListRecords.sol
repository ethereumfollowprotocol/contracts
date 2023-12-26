// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title IEFPListMetadata
 */
interface IEFPListMetadata {
    event NewListMetadataValue(uint256 indexed nonce, string key, bytes value);

    struct KeyValue {
        string key;
        bytes value;
    }

    function getMetadataValue(uint256 nonce, string calldata key) external view returns (bytes memory);
    function getMetadataValues(uint256 nonce, string[] calldata keys) external view returns (bytes[] memory);
    function setMetadataValue(uint256 nonce, string calldata key, bytes calldata value) external;
    function setMetadataValues(uint256 nonce, KeyValue[] calldata records) external;

    // List Manager Functions
    function claimListManager(uint256 nonce) external;
    function claimListManagerForAddress(uint256 nonce, address manager) external;
    function getListManager(uint256 nonce) external view returns (address);
    function setListManager(uint256 nonce, address manager) external;

    // List User Functions
    function getListUser(uint256 nonce) external view returns (address);
    function setListUser(uint256 nonce, address user) external;
}

/**
 * @title IEFPListRecords
 * @notice Interface for the ListRecords contract.
 */
interface IEFPListRecords is IEFPListMetadata {
    // Events
    event ListOperation(uint256 indexed nonce, bytes op);

    // List Operation Functions - Read
    function getListOpCount(uint256 nonce) external view returns (uint256);
    function getListOp(uint256 nonce, uint256 index) external view returns (bytes memory);
    function getListOpsInRange(uint256 nonce, uint256 start, uint256 end) external view returns (bytes[] memory);
    function getAllListOps(uint256 nonce) external view returns (bytes[] memory);

    // List Operation Functions - Write
    function applyListOp(uint256 nonce, bytes calldata op) external;
    function applyListOps(uint256 nonce, bytes[] calldata ops) external;
}
