// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ListRecord} from "./ListRecord.sol";
import {List} from "./List.sol";

/**
 * @title TaggedList
 * @notice A TaggedList is a List that supports tagging a list record with a list of tags.
 */
contract TaggedList is List {

    // Event emitted when a tag is added to a record.
    event TagAdded(bytes32 indexed hash, string tag);

    // Event emitted when a tag is removed from a record.
    event TagRemoved(bytes32 indexed hash, string tag);

    // Mapping from recordHash to a secondary mapping that maps tags to a boolean.
    // This double-mapping effectively forms a set of tags for each record.
    mapping(bytes32 => mapping(string => bool)) private recordTags;

    ///////////////////////////////////////////////////////////////////////////
    // add
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Add a tag to a record.
     * @param recordHash The unique identifier of the record.
     * @param tag The tag to be added.
     */
    function addTagToRecord(bytes32 recordHash, string calldata tag) external {
        require(!recordTags[recordHash][tag], "Tag already exists for the record");
        recordTags[recordHash][tag] = true;
        emit TagAdded(recordHash, tag);
    }

    /**
     * @notice Adds a set of tags to a record.
     * @param recordHash The unique identifier of the record.
     * @param tags An array of tags to be added.
     */
    function addTagsToRecord(bytes32 recordHash, string[] calldata tags) external {
        for (uint i = 0; i < tags.length; i++) {
            // Ensure that the tag doesn't already exist for the record.
            require(!recordTags[recordHash][tags[i]], "Tag already exists for the record");

            // Add the tag.
            recordTags[recordHash][tags[i]] = true;

            // Emit the event.
            emit TagAdded(recordHash, tags[i]);
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // delete
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Removes a tag from a record.
     * @param recordHash The unique identifier of the record.
     * @param tag The tag to be removed.
     */
    function removeTagFromRecord(bytes32 recordHash, string calldata tag) external {
        require(recordTags[recordHash][tag], "Tag doesn't exist for the record");
        recordTags[recordHash][tag] = false;
        emit TagRemoved(recordHash, tag);
    }

    /**
     * @notice Removes a set of tags from a record.
     * @param recordHash The unique identifier of the record.
     * @param tags An array of tags to be removed.
     */
    function removeTagsFromRecord(bytes32 recordHash, string[] calldata tags) external {
        for (uint i = 0; i < tags.length; i++) {
            // Ensure that the tag exists for the record before removing.
            require(recordTags[recordHash][tags[i]], "Tag doesn't exist for the record");

            // Remove the tag.
            recordTags[recordHash][tags[i]] = false;

            // Emit the event.
            emit TagRemoved(recordHash, tags[i]);
        }
    }

    /**
     * @notice Checks if a record has a specific tag.
     * @param recordHash The unique identifier for the list record.
     * @param tag The tag to check.
     * @return bool True if the record has the tag, false otherwise.
     */
    function hasTag(bytes32 recordHash, string calldata tag) external view returns (bool) {
        return recordTags[recordHash][tag];
    }
}
