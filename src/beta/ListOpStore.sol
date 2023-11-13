// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IListRegistry} from "./IListRegistry.sol";
import {ListOp} from "./ListOp.sol";
import {ListRecord} from "./ListRecord.sol";

/**
 * @title Lists
 * @notice Manages a dynamic list of records associated with EFP List NFTs.
 *         Provides functionalities for list managers to append, modify, or delete records.
 */
contract Lists {

    ///////////////////////////////////////////////////////////////////////////
    // Events
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Emitted when an operation is applied to a list.
    /// @param nonce The unique identifier of the list being modified.
    /// @param code The operation code indicating the type of operation.
    /// @param data The data associated with the operation.
    event ListOperation(uint nonce, bytes1 code, bytes data);

    ///////////////////////////////////////////////////////////////////////////
    // Data Structures
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Maps each nonce to the address of its managing entity.
    /// @dev Nonces are unique identifiers for lists; each list has one manager.
    mapping(uint => address) public managers;

    /// @notice Stores a sequence of operations for each list identified by its nonce.
    /// @dev Each list can have multiple operations performed over time.
    mapping(uint => ListOp[]) public listOps;

    ///////////////////////////////////////////////////////////////////////////
    // Modifiers
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Ensures that the caller is the manager of the specified list.
     * @param nonce The unique identifier of the list.
     * @dev Used to restrict function access to the list's manager.
     */
    modifier onlyListManager(uint nonce) {
        require(managers[nonce] == msg.sender, "Not manager");
        _;
    }

    ///////////////////////////////////////////////////////////////////////////
    // List Manager Functions
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Allows an address to claim management of an unclaimed list nonce.
     * @param nonce The nonce that the sender wishes to claim.
     * @dev This function establishes the first-come-first-serve basis for nonce claiming.
     */
    function claimListManager(uint nonce) external {
        require(managers[nonce] == address(0), "Nonce already claimed");
        managers[nonce] = msg.sender;
    }

    /**
     * @notice Allows the current manager to transfer management of a list to a new address.
     * @param nonce The list's unique identifier.
     * @param manager The address to be set as the new manager.
     * @dev Only the current manager can transfer their management role.
     */
    function setListManager(uint nonce, address manager) external onlyListManager(nonce) {
        managers[nonce] = manager;
    }

    /**
     * @notice Retrieves the address of the manager for a specified list nonce.
     * @param nonce The list's unique identifier.
     * @return The address of the manager.
     */
    function getListManager(uint nonce) external view returns (address) {
        return managers[nonce];
    }

    ///////////////////////////////////////////////////////////////////////////
    // List Operation Functions
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Applies a single operation to the list.
     * @param nonce The list's unique identifier.
     * @param op The operation to be applied.
     * @dev Internal function, integral to the list modification process.
     */
    function _applyOp(uint nonce, ListOp calldata op) internal {
        listOps[nonce].push(op);
        emit ListOperation(nonce, op.code, op.data);
    }

    /**
     * @notice Public wrapper for `_applyOp`, enabling list managers to apply a single operation.
     * @param nonce The list's unique identifier.
     * @param op The operation to be applied.
     */
    function applyOp(uint nonce, ListOp calldata op) public onlyListManager(nonce) {
        _applyOp(nonce, op);
    }

    /**
     * @notice Allows list managers to apply multiple operations in a single transaction.
     * @param nonce The list's unique identifier.
     * @param ops An array of operations to be applied.
     * @dev Utilizes an unchecked loop for gas optimization.
     */
    function applyAllOps(uint nonce, ListOp[] calldata ops) public onlyListManager(nonce) {
        uint len = ops.length;
        for (uint i = 0; i < len; ) {
            _applyOp(nonce, ops[i]);
            unchecked {
                ++i;
            }
        }
    }
}
