// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { ABaseLists } from './ABaseLists.sol';
import { IListRegistry } from './IListRegistry.sol';
import { ListOperation } from './ListOperation.sol';
import { ListRecord } from './ListRecord.sol';

/**
 * @title DeletableListEntry
 * @notice Represents a list record entry that can be marked as deleted.
 */
struct DeletableListEntry {
    /// @dev Indicator for whether the record has been deleted.
    bool deleted;
    /// @dev The actual list record data.
    ListRecord record;
}

/**
 * @title ArrayLists
 * @notice This contract manages a list of records for each EFP List NFT,
 * providing functionalities to append, delete, and retrieve records. It
 * supports soft deletions, meaning the records are marked as deleted but not
 * actually removed from storage.
 */
contract ArrayLists is ABaseLists {
    /// @dev Dynamic array storing records with deletion markers.
    mapping(uint => DeletableListEntry[]) private recordsByNonce;

    /// @dev Maps the hash of a record to its position in the records array for efficient lookup.
    /// Uses non-zero defaulting (i.e., actual position is stored + 1) to check for existence.
    mapping(uint => mapping(bytes32 => uint)) private recordIndexByNonce;

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
    ) internal override {
        bytes32 hash = keccak256(abi.encode(version, recordType, data));
        require(recordIndexByNonce[nonce][hash] == 0, 'Record already exists!');

        recordsByNonce[nonce].push(
            DeletableListEntry(false, ListRecord(version, recordType, data))
        );
        // store the index so we can look it up later for deletion
        recordIndexByNonce[nonce][hash] = recordsByNonce[nonce].length;
        emit RecordAdded(nonce, hash);
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
    function _deleteRecord(uint nonce, bytes32 recordHash) internal override {
        mapping(bytes32 => uint) storage recordIndices = recordIndexByNonce[
            nonce
        ];
        require(recordIndices[recordHash] > 0, 'Record not found');

        uint indexToDelete = recordIndices[recordHash] - 1;
        // mark the record as deleted
        recordsByNonce[nonce][indexToDelete].deleted = true;
        // remove the index
        delete recordIndices[recordHash];
        emit RecordDeleted(nonce, recordHash);
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
    ) internal virtual override {
        if (operation.operationType == OPERATION_APPEND) {
            ListRecord memory record = abi.decode(operation.data, (ListRecord));
            _appendRecord(
                nonce,
                record.version,
                record.recordType,
                record.data
            );
        } else if (operation.operationType == OPERATION_DELETE) {
            bytes32 recordHash = abi.decode(operation.data, (bytes32));
            _deleteRecord(nonce, recordHash);
        } else {
            revert('Invalid operation type');
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Read APIs
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Returns the total count of records for a specific nonce, including those marked as deleted.
     *
     * @param nonce The nonce of the list.
     * @return Total number of records for the specified nonce.
     */
    function getRecordCount(uint nonce) public view returns (uint) {
        return recordsByNonce[nonce].length;
    }

    /**
     * @notice Retrieves a specific record by its position for a specific nonce.
     *
     * @param nonce The nonce of the list.
     * @param index The position of the desired record in the list.
     * @return The record at the specified position for the specified nonce.
     */
    function getRecord(
        uint nonce,
        uint index
    ) public view returns (DeletableListEntry memory) {
        require(index < recordsByNonce[nonce].length, 'Index out of bounds');
        return recordsByNonce[nonce][index];
    }

    /**
     * @notice Retrieves all the records for a specific nonce.
     *
     * @param nonce The nonce of the list.
     * @return An array of all records for the specified nonce.
     */
    function getRecords(
        uint nonce
    ) public view returns (DeletableListEntry[] memory) {
        return getRecordsInRange(nonce, 0, recordsByNonce[nonce].length - 1);
    }

    /**
     * @notice Retrieves records in a specified range of positions for a specific nonce.
     *
     * @param nonce The nonce of the list.
     * @param fromIndex The start position for the range.
     * @param toIndex The end position for the range.
     * @return An array of records within the specified range for the specified nonce.
     */
    function getRecordsInRange(
        uint nonce,
        uint fromIndex,
        uint toIndex
    ) public view returns (DeletableListEntry[] memory) {
        require(fromIndex <= toIndex, 'Invalid range');
        require(toIndex < recordsByNonce[nonce].length, 'Index out of bounds');

        DeletableListEntry[] memory result = new DeletableListEntry[](
            toIndex - fromIndex + 1
        );
        for (uint i = fromIndex; i <= toIndex; ) {
            result[i - fromIndex] = recordsByNonce[nonce][i];

            unchecked {
                ++i;
            }
        }
        return result;
    }
}
