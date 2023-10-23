// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ListRecord} from "./ListRecord.sol";
import {Lists} from "./Lists.sol";
import {IListRegistry} from "./IListRegistry.sol";

interface ITags {

    ///////////////////////////////////////////////////////////////////////////
    // add
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Add a tag to a record.
     * @param tokenId The token ID of the list for which add tag to a record.
     * @param recordHash The unique identifier of the record.
     * @param tag The tag to be added.
     */
    function addTagToRecord(uint tokenId, bytes32 recordHash, string calldata tag) external;

    /**
     * @notice Adds a set of tags to a record.
     * @param tokenId The token ID of the list for which add tags to a record.
     * @param recordHash The unique identifier of the record.
     * @param tags An array of tags to be added.
     */
    function addTagsToRecord(uint tokenId, bytes32 recordHash, string[] calldata tags) external;

    ///////////////////////////////////////////////////////////////////////////
    // delete
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Removes a tag from a record.
     * @param tokenId The token ID of the list for which to delete tag from a record.
     * @param recordHash The unique identifier of the record.
     * @param tag The tag to be deleted.
     */
    function deleteTagFromRecord(uint tokenId, bytes32 recordHash, string calldata tag) external;

    /**
     * @notice Removes a set of tags from a record.
     * @param tokenId The token ID of the list for which to delete tags from a record.
     * @param recordHash The unique identifier of the record.
     * @param tags An array of tags to be deleted.
     */
    function deleteTagsFromRecord(uint tokenId, bytes32 recordHash, string[] calldata tags) external;

    /**
     * @notice Checks if a record has a specific tag.
     * @param tokenId The token ID of the list for which to check if a record has a tag.
     * @param recordHash The unique identifier for the list record.
     * @param tag The tag to check.
     * @return bool True if the record has the tag, false otherwise.
     */
    function hasTag(uint tokenId, bytes32 recordHash, string calldata tag) external view returns (bool);
}
