// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IListRegistry} from "./IListRegistry.sol";
import {ITags} from "./ITags.sol";
import {ListOperation} from "./ListOperation.sol";
import {ListRecord} from "./ListRecord.sol";
import {Lists} from "./Lists.sol";

/**
 * @title TaggedList
 * @notice A TaggedList is a List that supports tagging a list record with a list of tags.
 */
contract Tags is ITags, Lists {

    // Mapping from recordHash to a secondary mapping that maps tags to a boolean.
    // This double-mapping effectively forms a set of tags for each record.
    mapping(uint => mapping(bytes32 => mapping(string => bool))) private recordTagsByTokenId;

    ///////////////////////////////////////////////////////////////////////////
    // Events
    ///////////////////////////////////////////////////////////////////////////

    // Event emitted when a tag is added to a record.
    event TagAdded(uint tokenId, bytes32 indexed hash, string tag);

    // Event emitted when a tag is deleted from a record.
    event TagRemoved(uint tokenId, bytes32 indexed hash, string tag);

    ///////////////////////////////////////////////////////////////////////////
    // Constants
    ///////////////////////////////////////////////////////////////////////////

    /// @dev Operation type for appending a tag to a record.
    uint8 public constant OPERATION_ADD_TAG = 3;

    /// @dev Operation type for deleting a tag from a record.
    uint8 public constant OPERATION_DELETE_TAG = 4;

    ///////////////////////////////////////////////////////////////////////////
    // Constructor
    ///////////////////////////////////////////////////////////////////////////

    constructor(IListRegistry listRegistry_) Lists(listRegistry_) {}

    ///////////////////////////////////////////////////////////////////////////
    // Write APIs
    ///////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////
    // Write - Add tag(s)
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Add a tag to a record.
     * @param tokenId The token ID of the list for which add tag to a record.
     * @param recordHash The unique identifier of the record.
     * @param tag The tag to be added.
     */
    function _addTagToRecord(uint tokenId, bytes32 recordHash, string memory tag) internal {
            // Ensure that the tag doesn't already exist for the record
        require(!recordTagsByTokenId[tokenId][recordHash][tag], "Tag already exists for the record");

            // Add the tag
        recordTagsByTokenId[tokenId][recordHash][tag] = true;

            // Emit the event
        emit TagAdded(tokenId, recordHash, tag);
    }

    /**
     * @notice Add a tag to a record.
     * @param tokenId The token ID of the list for which add tag to a record.
     * @param recordHash The unique identifier of the record.
     * @param tag The tag to be added.
     */
    function addTagToRecord(uint tokenId, bytes32 recordHash, string calldata tag) external onlyListManager(tokenId) {
        _addTagToRecord(tokenId, recordHash, tag);
    }

    /**
     * @notice Adds a set of tags to a record.
     * @param tokenId The token ID of the list for which add tags to a record.
     * @param recordHash The unique identifier of the record.
     * @param tags An array of tags to be added.
     */
    function addTagsToRecord(uint tokenId, bytes32 recordHash, string[] calldata tags) external onlyListManager(tokenId) {
        for (uint i = 0; i < tags.length; i++) {
            _addTagToRecord(tokenId, recordHash, tags[i]);
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write - delete tag(s)
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Removes a tag from a record.
     * @param tokenId The token ID of the list for which to delete tag from a record.
     * @param recordHash The unique identifier of the record.
     * @param tag The tag to be deleted.
     */
    function _deleteTagFromRecord(uint tokenId, bytes32 recordHash, string memory tag) internal {
            // Ensure that the tag doesn't already exist for the record
        require(recordTagsByTokenId[tokenId][recordHash][tag], "Tag doesn't exist for the record");

        // Remove the tag
        recordTagsByTokenId[tokenId][recordHash][tag] = false;

        // Emit the event
        emit TagRemoved(tokenId, recordHash, tag);
    }

    /**
     * @notice Removes a tag from a record.
     * @param tokenId The token ID of the list for which to delete tag from a record.
     * @param recordHash The unique identifier of the record.
     * @param tag The tag to be deleted.
     */
    function deleteTagFromRecord(uint tokenId, bytes32 recordHash, string calldata tag) external onlyListManager(tokenId) {
        _deleteTagFromRecord(tokenId, recordHash, tag);
    }

    /**
     * @notice Removes a set of tags from a record.
     * @param tokenId The token ID of the list for which to delete tags from a record.
     * @param recordHash The unique identifier of the record.
     * @param tags An array of tags to be deleted.
     */
    function deleteTagsFromRecord(uint tokenId, bytes32 recordHash, string[] calldata tags) external onlyListManager(tokenId) {
        for (uint i = 0; i < tags.length; i++) {
            _deleteTagFromRecord(tokenId, recordHash, tags[i]);
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
    function _modifyRecord(uint tokenId, ListOperation calldata operation) internal override {
        if (operation.operationType == OPERATION_APPEND) {
            ListRecord memory record = abi.decode(operation.data, (ListRecord));
            _appendRecord(tokenId, record.version, record.recordType, record.data);
        } else if (operation.operationType == OPERATION_DELETE) {
            bytes32 recordHash = abi.decode(operation.data, (bytes32));
            _deleteRecord(tokenId, recordHash);
        } else if (operation.operationType == OPERATION_ADD_TAG) {
            // the data should be a bytes32 recordHash followed by a string tag
            (bytes32 recordHash, string memory tag) = abi.decode(operation.data, (bytes32, string));
            _addTagToRecord(tokenId, recordHash, tag);
        } else if (operation.operationType == OPERATION_DELETE_TAG) {
            (bytes32 recordHash, string memory tag) = abi.decode(operation.data, (bytes32, string));
            _deleteTagFromRecord(tokenId, recordHash, tag);
        } else {
            revert("Invalid operation type");
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Read APIs
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Checks if a record has a specific tag.
     * @param tokenId The token ID of the list for which to check if a record has a tag.
     * @param recordHash The unique identifier for the list record.
     * @param tag The tag to check.
     * @return bool True if the record has the tag, false otherwise.
     */
    function hasTag(uint tokenId, bytes32 recordHash, string calldata tag) external view returns (bool) {
        return recordTagsByTokenId[tokenId][recordHash][tag];
    }
}
