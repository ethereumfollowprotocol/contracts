// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ListRecord} from "../ListRecord.sol";

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
 * @title List
 * @notice This contract manages a list of records, providing functionalities to append,
 * delete, and retrieve records. It supports soft deletions, meaning the records are marked
 * as deleted but not actually removed from storage.
 */
contract List {
    /// @dev Dynamic array storing records with deletion markers.
    DeletableListEntry[] private records;

    /// @dev Maps the hash of a record to its position in the records array for efficient lookup.
    /// Uses non-zero defaulting (i.e., actual position is stored + 1) to check for existence.
    mapping(bytes32 => uint) private recordIndex;

    /// @dev Emitted when a new record is added to the list.
    event RecordAdded(bytes32 recordHash);

    /// @dev Emitted when a record is marked as deleted.
    event RecordDeleted(bytes32 recordHash);

    /**
     * @notice Appends a record to the end of the list.
     * @param version The version number of the record.
     * @param recordType The type identifier of the record.
     * @param data The actual data content of the record.
     */
    function appendRecord(uint8 version, uint8 recordType, bytes memory data) public {
        bytes32 hash = keccak256(abi.encode(version, recordType, data));
        require(recordIndex[hash] == 0, "Record already exists!");

        DeletableListEntry memory newRecord = DeletableListEntry(false, ListRecord(version, recordType, data));
        records.push(newRecord);
        recordIndex[hash] = records.length; // Using length instead of length - 1 for 0 default check
        emit RecordAdded(hash);
    }

    /**
     * @notice Marks a record as deleted. This is a soft delete; the record remains but is flagged.
     * @param recordHash The hash identifier of the record to delete.
     */
    function deleteRecord(bytes32 recordHash) public {
        require(recordIndex[recordHash] > 0 && !records[recordIndex[recordHash] - 1].deleted, "Record not found or already deleted");

        uint indexToDelete = recordIndex[recordHash] - 1;
        records[indexToDelete].deleted = true;
        delete recordIndex[recordHash];
        emit RecordDeleted(recordHash);
    }

    /**
     * @notice Returns the total count of records, including those marked as deleted.
     * @return Total number of records.
     */
    function getRecordCount() public view returns (uint) {
        return records.length;
    }

    /**
     * @notice Retrieves a specific record by its position.
     * @param index The position of the desired record in the list.
     * @return The record at the specified position.
     */
    function getRecord(uint index) public view returns (ListRecord memory) {
        require(index < records.length, "Index out of bounds");
        return records[index].record;
    }

    /**
     * @notice Retrieves all the records.
     * @return An array of all records.
     */
    function getRecords() public view returns (ListRecord[] memory) {
        return getRecordsInRange(0, records.length - 1);
    }

    /**
     * @notice Retrieves records in a specified range of positions.
     * @param fromIndex The start position for the range.
     * @param toIndex The end position for the range.
     * @return An array of records within the specified range.
     */
    function getRecordsInRange(uint fromIndex, uint toIndex) public view returns (ListRecord[] memory) {
        require(fromIndex <= toIndex, "Invalid range");
        require(toIndex < records.length, "Index out of bounds");

        ListRecord[] memory result = new ListRecord[](toIndex - fromIndex + 1);
        for (uint i = fromIndex; i <= toIndex; i++) {
            result[i - fromIndex] = records[i].record;
        }
        return result;
    }
}
