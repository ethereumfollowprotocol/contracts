// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IListRegistry} from "./IListRegistry.sol";
import {ListRecord} from "./ListRecord.sol";

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
 * @title ListOperation
 * @notice Represents an operation to be performed on a list.
 */
struct ListOperation {
    uint8 operationType;
    bytes data;
}

/**
 * @title BaseLists
 * @notice This contract manages a list of records for each EFP List NFT,
 * providing functionalities to append, delete, and retrieve records. It
 * supports soft deletions, meaning the records are marked as deleted but not
 * actually removed from storage.
 */
contract BaseLists {
    /// @dev Dynamic array storing records with deletion markers.
    mapping(uint => DeletableListEntry[]) private recordsByTokenId;

    /// @dev Maps the hash of a record to its position in the records array for efficient lookup.
    /// Uses non-zero defaulting (i.e., actual position is stored + 1) to check for existence.
    mapping(uint => mapping(bytes32 => uint)) private recordIndexByTokenId;

    ///////////////////////////////////////////////////////////////////////////
    // Events
    ///////////////////////////////////////////////////////////////////////////

    /// @dev Emitted when a new record is added to the list.
    event RecordAdded(uint tokenId, bytes32 recordHash);

    /// @dev Emitted when a record is marked as deleted.
    event RecordDeleted(uint tokenId, bytes32 recordHash);

    ///////////////////////////////////////////////////////////////////////////
    // Constants
    ///////////////////////////////////////////////////////////////////////////
    uint8 public constant OPERATION_APPEND = 1;
    uint8 public constant OPERATION_DELETE = 2;

    ///////////////////////////////////////////////////////////////////////////
    // Modifiers
    ///////////////////////////////////////////////////////////////////////////

    /**
     * Restricts access to the owner of the specified token.
     * @param tokenId The ID of the token whose owner is to be checked.
     */
    modifier onlyListManager(uint tokenId) virtual {
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
     * @param tokenId The token ID of the list for which to append.
     * @param version The version number of the record.
     * @param recordType The type identifier of the record.
     * @param data The actual data content of the record.
     */
    function _appendRecord(uint tokenId, uint8 version, uint8 recordType, bytes memory data) internal {
        bytes32 hash = keccak256(abi.encode(version, recordType, data));
        require(recordIndexByTokenId[tokenId][hash] == 0, "Record already exists!");

        DeletableListEntry memory newRecord = DeletableListEntry(false, ListRecord(version, recordType, data));
        recordsByTokenId[tokenId].push(newRecord);
        recordIndexByTokenId[tokenId][hash] = recordsByTokenId[tokenId].length; // Using length for 0 default check
        emit RecordAdded(tokenId, hash);
    }

    /**
     * @notice Appends a record to the end of the list.
     *
     * @param tokenId The token ID of the list for which to append.
     * @param version The version number of the record.
     * @param recordType The type identifier of the record.
     * @param data The actual data content of the record.
     */
    function appendRecord(uint tokenId, uint8 version, uint8 recordType, bytes calldata data) public onlyListManager(tokenId) {
        _appendRecord(tokenId, version, recordType, data);
    }

    /**
     * @notice Appends an array of records to the end of the list.
     *
     * @param tokenId The token ID of the list for which to append.
     * @param records The array of records to append.
     */
    function appendRecords(uint tokenId, ListRecord[] calldata records) public onlyListManager(tokenId) {
        for (uint i = 0; i < records.length; i++) {
            _appendRecord(tokenId, records[i].version, records[i].recordType, records[i].data);
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write - Delete
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Marks a record as deleted. This is a soft delete; the record remains but is flagged.
     *
     * @param tokenId The token ID of the list for which to delete record.
     * @param recordHash The hash identifier of the record to delete.
     */
    function _deleteRecord(uint tokenId, bytes32 recordHash) internal {
        mapping(bytes32 => uint) storage recordIndices = recordIndexByTokenId[tokenId];
        require(recordIndices[recordHash] > 0 && !recordsByTokenId[tokenId][recordIndices[recordHash] - 1].deleted, "Record not found or already deleted");

        uint indexToDelete = recordIndices[recordHash] - 1;
        recordsByTokenId[tokenId][indexToDelete].deleted = true;
        delete recordIndices[recordHash];
        emit RecordDeleted(tokenId, recordHash);
    }

    /**
     * @notice Marks a record as deleted. This is a soft delete; the record remains but is flagged.
     *
     * @param tokenId The token ID of the list for which to delete record.
     * @param recordHash The hash identifier of the record to delete.
     */
    function deleteRecord(uint tokenId, bytes32 recordHash) public onlyListManager(tokenId) {
        _deleteRecord(tokenId, recordHash);
    }

    /**
     * @notice Marks an array of records as deleted. This is a soft delete; the records remain but are flagged.
     *
     * @param tokenId The token ID of the list for which to delete record.
     * @param recordHashes The array of record hashes to delete.
     */
    function deleteRecords(uint tokenId, bytes32[] calldata recordHashes) public onlyListManager(tokenId) {
        for (uint i = 0; i < recordHashes.length; i++) {
            _deleteRecord(tokenId, recordHashes[i]);
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write - Modify
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Perform a generalized modification to the list.
     *
     * @param tokenId The token ID of the list for which to modify records.
     * @param operation The operation to perform.
     */
    function _modifyRecord(uint tokenId, ListOperation calldata operation) internal {
        if (operation.operationType == OPERATION_APPEND) {
            ListRecord memory record = abi.decode(operation.data, (ListRecord));
            _appendRecord(tokenId, record.version, record.recordType, record.data);
        } else if (operation.operationType == OPERATION_DELETE) {
            bytes32 recordHash = abi.decode(operation.data, (bytes32));
            _deleteRecord(tokenId, recordHash);
        } else {
            revert("Invalid operation type");
        }
    }

    /**
     * @notice Perform a generalized modification to the list.
     *
     * @param tokenId The token ID of the list for which to modify records.
     * @param operation The operation to perform.
     */
    function modifyRecord(uint tokenId, ListOperation calldata operation) public onlyListManager(tokenId) {
        _modifyRecord(tokenId, operation);
    }

    /**
     * @notice Perform a generalized modification to the list.
     *
     * @param tokenId The token ID of the list for which to modify records.
     * @param operations The array of operations to perform.
     */
    function modifyRecords(uint tokenId, ListOperation[] calldata operations) public onlyListManager(tokenId) {
        for (uint i = 0; i < operations.length; i++) {
            _modifyRecord(tokenId, operations[i]);
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Read APIs
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Returns the total count of records for a specific tokenId, including those marked as deleted.
     *
     * @param tokenId The ID of the token whose record count is desired.
     * @return Total number of records for the specified tokenId.
     */
    function getRecordCount(uint tokenId) public view returns (uint) {
        return recordsByTokenId[tokenId].length;
    }

    /**
     * @notice Retrieves a specific record by its position for a specific tokenId.
     *
     * @param tokenId The ID of the token whose record is desired.
     * @param index The position of the desired record in the list.
     * @return The record at the specified position for the specified tokenId.
     */
    function getRecord(uint tokenId, uint index) public view returns (DeletableListEntry memory) {
        require(index < recordsByTokenId[tokenId].length, "Index out of bounds");
        return recordsByTokenId[tokenId][index];
    }

    /**
     * @notice Retrieves all the records for a specific tokenId.
     *
     * @param tokenId The ID of the token whose records are desired.
     * @return An array of all records for the specified tokenId.
     */
    function getRecords(uint tokenId) public view returns (DeletableListEntry[] memory) {
        return getRecordsInRange(tokenId, 0, recordsByTokenId[tokenId].length - 1);
    }

    /**
     * @notice Retrieves records in a specified range of positions for a specific tokenId.
     *
     * @param tokenId The ID of the token whose records are desired.
     * @param fromIndex The start position for the range.
     * @param toIndex The end position for the range.
     * @return An array of records within the specified range for the specified tokenId.
     */
    function getRecordsInRange(uint tokenId, uint fromIndex, uint toIndex) public view returns (DeletableListEntry[] memory) {
        require(fromIndex <= toIndex, "Invalid range");
        require(toIndex < recordsByTokenId[tokenId].length, "Index out of bounds");

        DeletableListEntry[] memory result = new DeletableListEntry[](toIndex - fromIndex + 1);
        for (uint i = fromIndex; i <= toIndex; i++) {
            result[i - fromIndex] = recordsByTokenId[tokenId][i];
        }
        return result;
    }
}
