// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IEFPListRecords} from "./IEFPListRecords.sol";

/**
 * @title EFPListRecords
 * @notice Manages a dynamic list of records associated with EFP List NFTs.
 *         Provides functionalities for list managers to apply operations to their lists.
 */
contract EFPListRecords is IEFPListRecords, Ownable {
    ///////////////////////////////////////////////////////////////////////////
    // Data Structures
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Maps each nonce to the address of its managing entity.
    /// @dev Nonces are unique identifiers for lists; each list has one manager.
    mapping(uint256 => address) public managers;

    /// @notice Stores a sequence of operations for each list identified by its nonce.
    /// @dev Each list can have multiple operations performed over time.
    mapping(uint256 => bytes[]) public listOps;

    ///////////////////////////////////////////////////////////////////////////
    // Modifiers
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Ensures that the caller is the manager of the specified list.
     * @param nonce The unique identifier of the list.
     * @dev Used to restrict function access to the list's manager.
     */
    modifier onlyListManager(uint256 nonce) {
        require(managers[nonce] == msg.sender, "Not manager");
        _;
    }

    ///////////////////////////////////////////////////////////////////////////
    // List Manager Functions
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Allows an address to claim management of an unclaimed list nonce.
     * @param nonce The nonce that the sender wishes to claim.
     * @param manager The address to be set as the manager.
     * @dev This function establishes the first-come-first-serve basis for nonce claiming.
     */
    function _claimListManager(uint256 nonce, address manager) internal {
        require(managers[nonce] == address(0) || managers[nonce] == manager, "Nonce already claimed");
        managers[nonce] = manager;
        emit ListManagerChange(nonce, manager);
    }

    /**
     * @notice Allows the sender to claim management of an unclaimed list nonce.
     * @param nonce The nonce that the sender wishes to claim.
     */
    function claimListManager(uint256 nonce) external {
        _claimListManager(nonce, msg.sender);
    }

    /**
     * @notice Allows the sender to transfer management of a list to a new address.
     * @param nonce The list's unique identifier.
     * @param manager The address to be set as the new manager.
     */
    function claimListManagerForAddress(uint256 nonce, address manager) external {
        _claimListManager(nonce, manager);
    }

    /**
     * @notice Allows the current manager to transfer management of a list to a new address.
     * @param nonce The list's unique identifier.
     * @param manager The address to be set as the new manager.
     * @dev Only the current manager can transfer their management role.
     */
    function setListManager(uint256 nonce, address manager) external onlyListManager(nonce) {
        managers[nonce] = manager;
        emit ListManagerChange(nonce, manager);
    }

    /**
     * @notice Retrieves the address of the manager for a specified list nonce.
     * @param nonce The list's unique identifier.
     * @return The address of the manager.
     */
    function getListManager(uint256 nonce) external view returns (address) {
        return managers[nonce];
    }

    ///////////////////////////////////////////////////////////////////////////
    // List Operation Functions -  Read
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Retrieves the number of operations performed on a list.
     * @param nonce The list's unique identifier.
     * @return The number of operations performed on the list.
     */
    function getListOpCount(uint256 nonce) external view returns (uint256) {
        return listOps[nonce].length;
    }

    /**
     * @notice Retrieves the operation at a specified index for a list.
     * @param nonce The list's unique identifier.
     * @param index The index of the operation to be retrieved.
     * @return The operation at the specified index.
     */
    function getListOp(uint256 nonce, uint256 index) external view returns (bytes memory) {
        return listOps[nonce][index];
    }

    /**
     * @notice Retrieves a range of operations for a list.
     * @param nonce The list's unique identifier.
     * @param start The starting index of the range.
     * @param end The ending index of the range.
     * @return The operations in the specified range.
     */
    function getListOpsInRange(uint256 nonce, uint256 start, uint256 end) external view returns (bytes[] memory) {
        if (start > end) {
            revert("Invalid range");
        }

        bytes[] memory ops = new bytes[](end - start);
        for (uint256 i = start; i < end; ) {
            ops[i - start] = listOps[nonce][i];

            unchecked {
                ++i;
            }
        }
        return ops;
    }

    /**
     * @notice Retrieves all operations for a list.
     * @param nonce The list's unique identifier.
     * @return The operations performed on the list.
     */
    function getAllListOps(uint256 nonce) external view returns (bytes[] memory) {
        return listOps[nonce];
    }

    ///////////////////////////////////////////////////////////////////////////
    // List Operation Functions - Write
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Applies a single operation to the list.
     * @param nonce The list's unique identifier.
     * @param op The operation to be applied.
     */
    function _applyListOp(uint256 nonce, bytes calldata op) internal {
        listOps[nonce].push(op);
        emit ListOperation(nonce, op);
    }

    /**
     * @notice Public wrapper for `_applyOp`, enabling list managers to apply a single operation.
     * @param nonce The list's unique identifier.
     * @param op The operation to be applied.
     */
    function applyListOp(uint256 nonce, bytes calldata op) public onlyListManager(nonce) {
        _applyListOp(nonce, op);
    }

    /**
     * @notice Allows list managers to apply multiple operations in a single transaction.
     * @param nonce The list's unique identifier.
     * @param ops An array of operations to be applied.
     */
    function applyListOps(uint256 nonce, bytes[] calldata ops) public onlyListManager(nonce) {
        uint256 len = ops.length;
        for (uint256 i = 0; i < len; ) {
            _applyListOp(nonce, ops[i]);
            unchecked {
                ++i;
            }
        }
    }
}