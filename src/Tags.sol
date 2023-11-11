// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IListRegistry} from "./IListRegistry.sol";
import {ITags} from "./ITags.sol";
import {ListOperation} from "./ListOperation.sol";
import {ListRecord} from "./ListRecord.sol";
import {Lists} from "./Lists.sol";

/**
 * @title Tags
 * @notice A Tags is a List that supports tagging a list record with a list of tags.
 */
contract Tags is ITags, Lists {

    // Mapping from recordHash to a secondary mapping that maps tags to a boolean.
    // This double-mapping effectively forms a set of tags for each record.
    mapping(uint => mapping(bytes32 => mapping(string => bool))) private recordTagsByNonce;

    ///////////////////////////////////////////////////////////////////////////
    // Events
    ///////////////////////////////////////////////////////////////////////////

    // Event emitted when a tag is added to a record.
    event TagAdded(uint nonce, bytes32 indexed hash, string tag);

    // Event emitted when a tag is deleted from a record.
    event TagRemoved(uint nonce, bytes32 indexed hash, string tag);

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
     * @param nonce The nonce of the list for which add tag to a record.
     * @param recordHash The unique identifier of the record.
     * @param tag The tag to be added.
     */
    function _addTagToRecord(uint nonce, bytes32 recordHash, string memory tag) internal {
            // Ensure that the tag doesn't already exist for the record
        require(!recordTagsByNonce[nonce][recordHash][tag], "Tag already exists for the record");

            // Add the tag
        recordTagsByNonce[nonce][recordHash][tag] = true;

            // Emit the event
        emit TagAdded(nonce, recordHash, tag);
    }

    /**
     * @notice Add a tag to a record.
     * @param nonce The nonce of the list for which add tag to a record.
     * @param recordHash The unique identifier of the record.
     * @param tag The tag to be added.
     */
    function addTagToRecord(uint nonce, bytes32 recordHash, string calldata tag) external onlyListManager(nonce) {
        _addTagToRecord(nonce, recordHash, tag);
    }

    /**
     * @notice Adds a set of tags to a record.
     * @param nonce The nonce of the list for which add tags to a record.
     * @param recordHash The unique identifier of the record.
     * @param tags An array of tags to be added.
     */
    function addTagsToRecord(uint nonce, bytes32 recordHash, string[] calldata tags) external onlyListManager(nonce) {
        for (uint i = 0; i < tags.length; i++) {
            _addTagToRecord(nonce, recordHash, tags[i]);
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write - delete tag(s)
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Removes a tag from a record.
     * @param nonce The nonce of the list for which to delete tag from a record.
     * @param recordHash The unique identifier of the record.
     * @param tag The tag to be deleted.
     */
    function _deleteTagFromRecord(uint nonce, bytes32 recordHash, string memory tag) internal {
            // Ensure that the tag doesn't already exist for the record
        require(recordTagsByNonce[nonce][recordHash][tag], "Tag doesn't exist for the record");

        // Remove the tag
        recordTagsByNonce[nonce][recordHash][tag] = false;

        // Emit the event
        emit TagRemoved(nonce, recordHash, tag);
    }

    /**
     * @notice Removes a tag from a record.
     * @param nonce The nonce of the list for which to delete tag from a record.
     * @param recordHash The unique identifier of the record.
     * @param tag The tag to be deleted.
     */
    function deleteTagFromRecord(uint nonce, bytes32 recordHash, string calldata tag) external onlyListManager(nonce) {
        _deleteTagFromRecord(nonce, recordHash, tag);
    }

    /**
     * @notice Removes a set of tags from a record.
     * @param nonce The nonce of the list for which to delete tags from a record.
     * @param recordHash The unique identifier of the record.
     * @param tags An array of tags to be deleted.
     */
    function deleteTagsFromRecord(uint nonce, bytes32 recordHash, string[] calldata tags) external onlyListManager(nonce) {
        for (uint i = 0; i < tags.length; i++) {
            _deleteTagFromRecord(nonce, recordHash, tags[i]);
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
    function _modifyRecord(uint nonce, ListOperation calldata operation) internal override {
        if (operation.operationType == OPERATION_APPEND) {
            ListRecord memory record = abi.decode(operation.data, (ListRecord));
            _appendRecord(nonce, record.version, record.recordType, record.data);
        } else if (operation.operationType == OPERATION_DELETE) {
            bytes32 recordHash = abi.decode(operation.data, (bytes32));
            _deleteRecord(nonce, recordHash);
        } else if (operation.operationType == OPERATION_ADD_TAG) {
            // the data should be a bytes32 recordHash followed by a string tag
            (bytes32 recordHash, string memory tag) = abi.decode(operation.data, (bytes32, string));
            _addTagToRecord(nonce, recordHash, tag);
        } else if (operation.operationType == OPERATION_DELETE_TAG) {
            (bytes32 recordHash, string memory tag) = abi.decode(operation.data, (bytes32, string));
            _deleteTagFromRecord(nonce, recordHash, tag);
        } else {
            revert("Invalid operation type");
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Read APIs
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Checks if a record has a specific tag.
     * @param nonce The nonce of the list for which to check if a record has a tag.
     * @param recordHash The unique identifier for the list record.
     * @param tag The tag to check.
     * @return bool True if the record has the tag, false otherwise.
     */
    function hasTag(uint nonce, bytes32 recordHash, string calldata tag) external view returns (bool) {
        return recordTagsByNonce[nonce][recordHash][tag];
    }
}
