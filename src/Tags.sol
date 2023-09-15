// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IListRegistry} from "./IListRegistry.sol";
import {ITags} from "./ITags.sol";
import {ListRecord} from "./ListRecord.sol";
import {Lists} from "./Lists.sol";

/**
 * @title TaggedList
 * @notice A TaggedList is a List that supports tagging a list record with a list of tags.
 */
contract Tags is ITags, Lists {

    // Event emitted when a tag is added to a record.
    event TagAdded(uint tokenId, bytes32 indexed hash, string tag);

    // Event emitted when a tag is removed from a record.
    event TagRemoved(uint tokenId, bytes32 indexed hash, string tag);

    // Mapping from recordHash to a secondary mapping that maps tags to a boolean.
    // This double-mapping effectively forms a set of tags for each record.
    mapping(uint => mapping(bytes32 => mapping(string => bool))) private recordTagsByTokenId;

    constructor(IListRegistry listRegistry_) Lists(listRegistry_) {}

    ///////////////////////////////////////////////////////////////////////////
    // add
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Add a tag to a record.
     * @param tokenId The token ID of the list for which add tag to a record.
     * @param recordHash The unique identifier of the record.
     * @param tag The tag to be added.
     */
    function addTagToRecord(uint tokenId, bytes32 recordHash, string calldata tag) external onlyListManager(tokenId) {
        require(!recordTagsByTokenId[tokenId][recordHash][tag], "Tag already exists for the record");
        recordTagsByTokenId[tokenId][recordHash][tag] = true;
        emit TagAdded(tokenId, recordHash, tag);
    }

    /**
     * @notice Adds a set of tags to a record.
     * @param tokenId The token ID of the list for which add tags to a record.
     * @param recordHash The unique identifier of the record.
     * @param tags An array of tags to be added.
     */
    function addTagsToRecord(uint tokenId, bytes32 recordHash, string[] calldata tags) external onlyListManager(tokenId) {
        for (uint i = 0; i < tags.length; i++) {
            // Ensure that the tag doesn't already exist for the record.
            require(!recordTagsByTokenId[tokenId][recordHash][tags[i]], "Tag already exists for the record");

            // Add the tag.
            recordTagsByTokenId[tokenId][recordHash][tags[i]] = true;

            // Emit the event.
            emit TagAdded(tokenId, recordHash, tags[i]);
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // delete
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Removes a tag from a record.
     * @param tokenId The token ID of the list for which remove tag from a record.
     * @param recordHash The unique identifier of the record.
     * @param tag The tag to be removed.
     */
    function removeTagFromRecord(uint tokenId, bytes32 recordHash, string calldata tag) external onlyListManager(tokenId) {
        require(recordTagsByTokenId[tokenId][recordHash][tag], "Tag doesn't exist for the record");
        recordTagsByTokenId[tokenId][recordHash][tag] = false;
        emit TagRemoved(tokenId, recordHash, tag);
    }

    /**
     * @notice Removes a set of tags from a record.
     * @param tokenId The token ID of the list for which remove tags from a record.
     * @param recordHash The unique identifier of the record.
     * @param tags An array of tags to be removed.
     */
    function removeTagsFromRecord(uint tokenId, bytes32 recordHash, string[] calldata tags) external onlyListManager(tokenId) {
        for (uint i = 0; i < tags.length; i++) {
            // Ensure that the tag exists for the record before removing.
            require(recordTagsByTokenId[tokenId][recordHash][tags[i]], "Tag doesn't exist for the record");

            // Remove the tag.
            recordTagsByTokenId[tokenId][recordHash][tags[i]] = false;

            // Emit the event.
            emit TagRemoved(tokenId, recordHash, tags[i]);
        }
    }

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
