// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title IEFPLists
 * @notice Interface for the Lists contract.
 */
interface IEFPLists {
    // Events
    event ListManagerChange(uint indexed nonce, address manager);
    event ListOperation(uint indexed nonce, bytes op);

    // List Manager Functions
    function claimListManager(uint nonce) external;
    function setListManager(uint nonce, address manager) external;
    function getListManager(uint nonce) external view returns (address);

    // List Operation Functions - Read
    function getListOpCount(uint nonce) external view returns (uint);
    function getListOp(uint nonce, uint index) external view returns (bytes memory);
    function getListOpsInRange(uint nonce, uint start, uint end) external view returns (bytes[] memory);
    function getAllListOps(uint nonce) external view returns (bytes[] memory);

    // List Operation Functions - Write
    function applyListOp(uint nonce, bytes calldata op) external;
    function applyListOps(uint nonce, bytes[] calldata ops) external;
}
