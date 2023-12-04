// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title IEFPListRecords
 * @notice Interface for the ListRecords contract.
 */
interface IEFPListRecords {
    // Events
    event ListManagerChange(uint256 indexed nonce, address manager);
    event ListOperation(uint256 indexed nonce, bytes op);

    // List Manager Functions
    function claimListManager(uint256 nonce) external;
    function claimListManagerForAddress(uint256 nonce, address manager) external;
    function setListManager(uint256 nonce, address manager) external;
    function getListManager(uint256 nonce) external view returns (address);

    // List Operation Functions - Read
    function getListOpCount(uint256 nonce) external view returns (uint256);
    function getListOp(uint256 nonce, uint256 index) external view returns (bytes memory);
    function getListOpsInRange(uint256 nonce, uint256 start, uint256 end) external view returns (bytes[] memory);
    function getAllListOps(uint256 nonce) external view returns (bytes[] memory);

    // List Operation Functions - Write
    function applyListOp(uint256 nonce, bytes calldata op) external;
    function applyListOps(uint256 nonce, bytes[] calldata ops) external;
}
