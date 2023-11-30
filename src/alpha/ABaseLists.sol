// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { IListRegistry } from './IListRegistry.sol';
import { ListOperation } from './ListOperation.sol';
import { ListRecord } from './ListRecord.sol';

/**
 * @title BaseLists
 * @notice This contract manages a list of records for each EFP List NFT,
 * providing functionalities to append or delete records.
 */
abstract contract ABaseLists {
    ///////////////////////////////////////////////////////////////////////////
    // Events
    ///////////////////////////////////////////////////////////////////////////

    /// @dev Emitted when a new record is added to the list.
    event RecordAdded(uint nonce, bytes32 recordHash);

    /// @dev Emitted when a record is marked as deleted.
    event RecordDeleted(uint nonce, bytes32 recordHash);

    ///////////////////////////////////////////////////////////////////////////
    // Constants
    ///////////////////////////////////////////////////////////////////////////

    /// @dev Operation type for appending a record.
    uint8 public constant OPERATION_APPEND = 1;

    /// @dev Operation type for deleting a record.
    uint8 public constant OPERATION_DELETE = 2;

    ///////////////////////////////////////////////////////////////////////////
    // Modifiers
    ///////////////////////////////////////////////////////////////////////////

    /**
     * Restricts access to the owner of the specified token.
     * @param nonce The nonce for which to check the list manager.
     */
    modifier onlyListManager(uint nonce) virtual {
        _; // default implementation does nothing
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write APIs
    ///////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////
    // Write - Append
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Appends a record to the end of the list.
     *
     * @param nonce The nonce of the list for which to append.
     * @param version The version number of the record.
     * @param recordType The type identifier of the record.
     * @param data The actual data content of the record.
     */
    function _appendRecord(
        uint nonce,
        uint8 version,
        uint8 recordType,
        bytes memory data
    ) internal virtual;

    /**
     * @notice Appends a record to the end of the list.
     *
     * @param nonce The nonce of the list for which to append.
     * @param version The version number of the record.
     * @param recordType The type identifier of the record.
     * @param data The actual data content of the record.
     */
    function appendRecord(
        uint nonce,
        uint8 version,
        uint8 recordType,
        bytes calldata data
    ) public onlyListManager(nonce) {
        _appendRecord(nonce, version, recordType, data);
    }

    /**
     * @notice Appends an array of records to the end of the list.
     *
     * @param nonce The nonce of the list for which to append.
     * @param records The array of records to append.
     */
    function appendRecords(
        uint nonce,
        ListRecord[] calldata records
    ) public onlyListManager(nonce) {
        uint len = records.length;
        for (uint i = 0; i < len; ) {
            _appendRecord(
                nonce,
                records[i].version,
                records[i].recordType,
                records[i].data
            );
            unchecked {
                ++i;
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write - Delete
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Marks a record as deleted. This is a soft delete; the record remains but is flagged.
     *
     * @param nonce The nonce of the list for which to delete record.
     * @param recordHash The hash identifier of the record to delete.
     */
    function _deleteRecord(uint nonce, bytes32 recordHash) internal virtual;

    /**
     * @notice Marks a record as deleted. This is a soft delete; the record remains but is flagged.
     *
     * @param nonce The nonce of the list for which to delete record.
     * @param recordHash The hash identifier of the record to delete.
     */
    function deleteRecord(
        uint nonce,
        bytes32 recordHash
    ) public onlyListManager(nonce) {
        _deleteRecord(nonce, recordHash);
    }

    /**
     * @notice Marks an array of records as deleted. This is a soft delete; the records remain but are flagged.
     *
     * @param nonce The nonce of the list for which to delete record.
     * @param recordHashes The array of record hashes to delete.
     */
    function deleteRecords(
        uint nonce,
        bytes32[] calldata recordHashes
    ) public onlyListManager(nonce) {
        uint len = recordHashes.length;
        for (uint i = 0; i < len; ) {
            _deleteRecord(nonce, recordHashes[i]);

            unchecked {
                ++i;
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write - Modify
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Perform a generalized modification to the list.
     *
     * @param nonce The nonce of the list for which to modify records.
     * @param operation The operation to perform.
     */
    function _modifyRecord(
        uint nonce,
        ListOperation calldata operation
    ) internal virtual;

    /**
     * @notice Perform a generalized modification to the list.
     *
     * @param nonce The nonce of the list for which to modify records.
     * @param operation The operation to perform.
     */
    function modifyRecord(
        uint nonce,
        ListOperation calldata operation
    ) public onlyListManager(nonce) {
        _modifyRecord(nonce, operation);
    }

    /**
     * @notice Perform a generalized modification to the list.
     *
     * @param nonce The nonce of the list for which to modify records.
     * @param operations The array of operations to perform.
     */
    function modifyRecords(
        uint nonce,
        ListOperation[] calldata operations
    ) public onlyListManager(nonce) {
        uint len = operations.length;
        for (uint i = 0; i < len; ) {
            _modifyRecord(nonce, operations[i]);

            unchecked {
                ++i;
            }
        }
    }
}
