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
 * @title Lists
 * @notice This contract manages a list of records for each EFP List NFT,
 * providing functionalities to append, delete, and retrieve records. It
 * supports soft deletions, meaning the records are marked as deleted but not
 * actually removed from storage.
 */
contract Lists {
    /// @dev Dynamic array storing records with deletion markers.
    mapping(uint => DeletableListEntry[]) private recordsByTokenId;

    /// @dev Maps the hash of a record to its position in the records array for efficient lookup.
    /// Uses non-zero defaulting (i.e., actual position is stored + 1) to check for existence.
    mapping(uint => mapping(bytes32 => uint)) private recordIndexByTokenId;

    /// @dev Emitted when a new record is added to the list.
    event RecordAdded(uint tokenId, bytes32 recordHash);

    /// @dev Emitted when a record is marked as deleted.
    event RecordDeleted(uint tokenId, bytes32 recordHash);

    IListRegistry public listRegistry;

    constructor(IListRegistry listRegistry_) {
        // stubbed for now
        listRegistry = listRegistry_;
    }

    /**
     * Restricts access to the owner of the specified token.
     * @param tokenId The ID of the token whose owner is to be checked.
     */
    modifier onlyTokenOwner(uint tokenId) {
        // stubbed for now
        require(listRegistry.getManager(tokenId) == msg.sender, "Only EFP List Manager can call this function");
        _;
    }

    /**
     * @notice Appends a record to the end of the list.
     * @param tokenId The token ID of the list for which to append.
     * @param version The version number of the record.
     * @param recordType The type identifier of the record.
     * @param data The actual data content of the record.
     */
    function appendRecord(uint tokenId, uint8 version, uint8 recordType, bytes memory data) public onlyTokenOwner(tokenId) {
        bytes32 hash = keccak256(abi.encode(version, recordType, data));
        require(recordIndexByTokenId[tokenId][hash] == 0, "Record already exists!");

        DeletableListEntry memory newRecord = DeletableListEntry(false, ListRecord(version, recordType, data));
        recordsByTokenId[tokenId].push(newRecord);
        recordIndexByTokenId[tokenId][hash] = recordsByTokenId[tokenId].length; // Using length for 0 default check
        emit RecordAdded(tokenId, hash);
    }

    /**
     * @notice Marks a record as deleted. This is a soft delete; the record remains but is flagged.
     * @param tokenId The token ID of the list for which to delete record.
     * @param recordHash The hash identifier of the record to delete.
     */
    function deleteRecord(uint tokenId, bytes32 recordHash) public onlyTokenOwner(tokenId) {
        require(recordIndexByTokenId[tokenId][recordHash] > 0 && !recordsByTokenId[tokenId][recordIndexByTokenId[tokenId][recordHash] - 1].deleted, "Record not found or already deleted");

        uint indexToDelete = recordIndexByTokenId[tokenId][recordHash] - 1;
        recordsByTokenId[tokenId][indexToDelete].deleted = true;
        delete recordIndexByTokenId[tokenId][recordHash];
        emit RecordDeleted(tokenId, recordHash);
    }

    /**
     * @notice Returns the total count of records for a specific tokenId, including those marked as deleted.
     * @param tokenId The ID of the token whose record count is desired.
     * @return Total number of records for the specified tokenId.
     */
    function getRecordCount(uint tokenId) public view returns (uint) {
        return recordsByTokenId[tokenId].length;
    }

    /**
     * @notice Retrieves a specific record by its position for a specific tokenId.
     * @param tokenId The ID of the token whose record is desired.
     * @param index The position of the desired record in the list.
     * @return The record at the specified position for the specified tokenId.
     */
    function getRecord(uint tokenId, uint index) public view returns (ListRecord memory) {
        require(index < recordsByTokenId[tokenId].length, "Index out of bounds");
        return recordsByTokenId[tokenId][index].record;
    }

    /**
     * @notice Retrieves all the records for a specific tokenId.
     * @param tokenId The ID of the token whose records are desired.
     * @return An array of all records for the specified tokenId.
     */
    function getRecords(uint tokenId) public view returns (ListRecord[] memory) {
        return getRecordsInRange(tokenId, 0, recordsByTokenId[tokenId].length - 1);
    }

    /**
     * @notice Retrieves records in a specified range of positions for a specific tokenId.
     * @param tokenId The ID of the token whose records are desired.
     * @param fromIndex The start position for the range.
     * @param toIndex The end position for the range.
     * @return An array of records within the specified range for the specified tokenId.
     */
    function getRecordsInRange(uint tokenId, uint fromIndex, uint toIndex) public view returns (ListRecord[] memory) {
        require(fromIndex <= toIndex, "Invalid range");
        require(toIndex < recordsByTokenId[tokenId].length, "Index out of bounds");

        ListRecord[] memory result = new ListRecord[](toIndex - fromIndex + 1);
        for (uint i = fromIndex; i <= toIndex; i++) {
            result[i - fromIndex] = recordsByTokenId[tokenId][i].record;
        }
        return result;
    }
}
