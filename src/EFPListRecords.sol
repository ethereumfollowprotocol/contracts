// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IEFPListManager, IEFPListMetadata, IEFPListRecords} from "./interfaces/IEFPListRecords.sol";

/**
 * @title ListManager
 * @notice Manages ownership and access control for dynamic lists with unique nonces.
 *         Supports claiming, transferring, and retrieving list management rights.
 *         Each list is uniquely identified by a nonce, and only authorized entities
 *         can perform actions on their lists.
 */
abstract contract ListManager is IEFPListManager {
    ///////////////////////////////////////////////////////////////////////////
    // Data Structures
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Maps each nonce to the address of its managing entity.
    /// @dev Nonces are unique identifiers for lists; each list has one manager.
    mapping(uint256 => address) public managers;

    ///////////////////////////////////////////////////////////////////////////
    // Modifiers
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Ensures that the caller is the manager of the specified list.
     * @param nonce The unique identifier of the list.
     * @dev Used to restrict function access to the list's manager.
     */
    modifier onlyListManager(uint256 nonce) {
        require(managers[nonce] == msg.sender, "not manager");
        _;
    }

    ///////////////////////////////////////////////////////////////////////////
    // List Manager - Read
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Retrieves the address of the manager for a specified list nonce.
     * @param nonce The list's unique identifier.
     * @return The address of the manager.
     */
    function getListManager(uint256 nonce) external view returns (address) {
        return managers[nonce];
    }

    ///////////////////////////////////////////////////////////////////////////
    // List Manager - Write
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
}

/**
 * @title ListMetadata
 *
 * @notice Manages key-value pairs associated with EFP List NFTs.
 *         Provides functionalities for list managers to set and retrieve metadata for their lists.
 */
abstract contract ListMetadata is IEFPListMetadata, ListManager {
    ///////////////////////////////////////////////////////////////////////////
    // Data Structures
    ///////////////////////////////////////////////////////////////////////////

    /// @dev The key-value set for each token ID
    mapping(uint256 => mapping(string => bytes)) private values;

    /////////////////////////////////////////////////////////////////////////////
    // Getters
    /////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Retrieves metadata value for token ID and key.
     * @param tokenId The token Id to query.
     * @param key The key to query.
     * @return The associated value.
     */
    function getMetadataValue(uint256 tokenId, string calldata key) external view returns (bytes memory) {
        return values[tokenId][key];
    }

    /**
     * @dev Retrieves metadata values for token ID and keys.
     * @param tokenId The token Id to query.
     * @param keys The keys to query.
     * @return The associated values.
     */
    function getMetadataValues(uint256 tokenId, string[] calldata keys) external view returns (bytes[] memory) {
        uint256 length = keys.length;
        bytes[] memory result = new bytes[](length);
        for (uint256 i = 0; i < length; ) {
            string calldata key = keys[i];
            result[i] = values[tokenId][key];
            unchecked {
                ++i;
            }
        }
        return result;
    }

    /////////////////////////////////////////////////////////////////////////////
    // Setters
    /////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Sets metadata records for token ID with the unique key key to value,
     * overwriting anything previously stored for token ID and key. To clear a
     * field, set it to the empty string.
     * @param nonce The nonce corresponding to the list to update.
     * @param key The key to set.
     * @param value The value to set.
     */
    function _setMetadataValue(uint256 nonce, string calldata key, bytes calldata value) internal {
        values[nonce][key] = value;
        emit NewListMetadataValue(nonce, key, value);
    }

    /**
     * @dev Sets metadata records for token ID with the unique key key to value,
     * overwriting anything previously stored for token ID and key. To clear a
     * field, set it to the empty string. Only callable by the list manager.
     * @param nonce The nonce corresponding to the list to update.
     * @param key The key to set.
     * @param value The value to set.
     */
    function setMetadataValue(
        uint256 nonce,
        string calldata key,
        bytes calldata value
    ) external onlyListManager(nonce) {
        _setMetadataValue(nonce, key, value);
    }

    /**
     * @dev Sets an array of metadata records for a token ID. Each record is a
     * key/value pair. Only callable by the list manager.
     * @param nonce The nonce corresponding to the list to update.
     * @param records The records to set.
     */
    function setMetadataValues(uint256 nonce, KeyValue[] calldata records) external onlyListManager(nonce) {
        uint256 length = records.length;
        for (uint256 i = 0; i < length; ) {
            KeyValue calldata record = records[i];
            _setMetadataValue(nonce, record.key, record.value);
            unchecked {
                ++i;
            }
        }
    }
}

/**
 * @title EFPListRecords
 * @notice Manages a dynamic list of records associated with EFP List NFTs.
 *         Provides functionalities for list managers to apply operations to their lists.
 */
abstract contract ListRecords is IEFPListRecords, ListManager {
    ///////////////////////////////////////////////////////////////////////////
    // Data Structures
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Stores a sequence of operations for each list identified by its nonce.
    /// @dev Each list can have multiple operations performed over time.
    mapping(uint256 => bytes[]) public listOps;

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

contract EFPListRecords is ListRecords, ListMetadata, Ownable {}
