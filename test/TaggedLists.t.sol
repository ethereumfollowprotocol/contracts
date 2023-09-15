// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Tags.sol";
import {ListRegistry} from "../src/ListRegistry.sol";

contract tagsTest is Test {
    ListRegistry public listRegistry;
    Tags public tags;
    uint8 constant VERSION = 1;
    uint8 constant RAW_ADDRESS = 1;
    uint constant TOKEN_ID = 0;

    function setUp() public {
        listRegistry = new ListRegistry();
        tags = new Tags(listRegistry);
    }

    function _createSampleRecord() internal returns (bytes32) {
        // Append a record
        tags.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));

        // Get the hash of the record to use as an identifier
        bytes32 hash = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xAbc123")));
        return hash;
    }

    function testAddSingleTagToRecord() public {
        listRegistry.mint();

        bytes32 hash = _createSampleRecord();

        // Check that the record doesn't initially have the tag
        assert(!tags.hasTag(TOKEN_ID, hash, "Tag1"));

        // Add a tag to the record using the single tag API
        tags.addTagToRecord(TOKEN_ID, hash, "Tag1");

        // Now check that the record has the tag
        assert(tags.hasTag(TOKEN_ID, hash, "Tag1"));
    }

    function testRemoveSingleTagFromRecord() public {
        listRegistry.mint();

        bytes32 hash = _createSampleRecord();

        // Add a tag to the record using the single tag API
        tags.addTagToRecord(TOKEN_ID, hash, "Tag1");
        assert(tags.hasTag(TOKEN_ID, hash, "Tag1"));

        // Remove the tag from the record using the single tag API
        tags.removeTagFromRecord(TOKEN_ID, hash, "Tag1");

        // Check that the tag has been removed
        assert(!tags.hasTag(TOKEN_ID, hash, "Tag1"));
    }

    function testMultipleTags() public {
        listRegistry.mint();

        bytes32 hash = _createSampleRecord();

        // Continue using the array API for multiple tags
        string[] memory tagsToAdd = new string[](2);
        tagsToAdd[0] = "Tag1";
        tagsToAdd[1] = "Tag2";
        tags.addTagsToRecord(TOKEN_ID, hash, tagsToAdd);
        assert(tags.hasTag(TOKEN_ID, hash, "Tag1"));
        assert(tags.hasTag(TOKEN_ID, hash, "Tag2"));

        // Remove multiple tags from the record
        string[] memory tagsToRemove = new string[](2);
        tagsToRemove[0] = "Tag1";
        tagsToRemove[1] = "Tag2";
        tags.removeTagsFromRecord(TOKEN_ID, hash, tagsToRemove);

        // Ensure both tags have been removed
        assert(!tags.hasTag(TOKEN_ID, hash, "Tag1"));
        assert(!tags.hasTag(TOKEN_ID, hash, "Tag2"));
    }

    function testRepeatedOperations() public {
        listRegistry.mint();

        bytes32 hash = _createSampleRecord();

        // Add a single tag using the single tag API
        tags.addTagToRecord(TOKEN_ID, hash, "Tag1");
        assert(tags.hasTag(TOKEN_ID, hash, "Tag1"));

        // Expect a revert when trying to add an existing tag using the single tag API
        vm.expectRevert("Tag already exists for the record");
        tags.addTagToRecord(TOKEN_ID, hash, "Tag1");

        // This tag was never added. Use the single tag API to try and remove it.
        vm.expectRevert("Tag doesn't exist for the record");
        tags.removeTagFromRecord(TOKEN_ID, hash, "Tag3");
    }

    function testInteractionsWithListFunctions() public {
        listRegistry.mint();

        bytes32 hash = _createSampleRecord();

        // Add a single tag using the single tag API
        tags.addTagToRecord(TOKEN_ID, hash, "Tag1");
        assert(tags.hasTag(TOKEN_ID, hash, "Tag1"));

        // Soft delete the record
        tags.deleteRecord(TOKEN_ID, hash);

        // Ensure we can still fetch the tag
        assert(tags.hasTag(TOKEN_ID, hash, "Tag1"));
    }
}
