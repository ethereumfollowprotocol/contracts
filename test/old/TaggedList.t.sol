// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/old/TaggedList.sol";

contract TaggedListTest is Test {
    TaggedList public taggedList;
    uint8 constant VERSION = 1;
    uint8 constant RAW_ADDRESS = 1;

    function setUp() public {
        taggedList = new TaggedList();
    }

    function _createSampleRecord() internal returns (bytes32) {
        // Append a record
        taggedList.appendRecord(VERSION, RAW_ADDRESS, bytes("0xAbc123"));

        // Get the hash of the record to use as an identifier
        bytes32 hash = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xAbc123")));
        return hash;
    }

    function testAddSingleTagToRecord() public {
        bytes32 hash = _createSampleRecord();

        // Check that the record doesn't initially have the tag
        assert(!taggedList.hasTag(hash, "Tag1"));

        // Add a tag to the record using the single tag API
        taggedList.addTagToRecord(hash, "Tag1");

        // Now check that the record has the tag
        assert(taggedList.hasTag(hash, "Tag1"));
    }

    function testRemoveSingleTagFromRecord() public {
        bytes32 hash = _createSampleRecord();

        // Add a tag to the record using the single tag API
        taggedList.addTagToRecord(hash, "Tag1");
        assert(taggedList.hasTag(hash, "Tag1"));

        // Remove the tag from the record using the single tag API
        taggedList.removeTagFromRecord(hash, "Tag1");

        // Check that the tag has been removed
        assert(!taggedList.hasTag(hash, "Tag1"));
    }

    function testMultipleTags() public {
        bytes32 hash = _createSampleRecord();

        // Continue using the array API for multiple tags
        string[] memory tagsToAdd = new string[](2);
        tagsToAdd[0] = "Tag1";
        tagsToAdd[1] = "Tag2";
        taggedList.addTagsToRecord(hash, tagsToAdd);
        assert(taggedList.hasTag(hash, "Tag1"));
        assert(taggedList.hasTag(hash, "Tag2"));

        // Remove multiple tags from the record
        string[] memory tagsToRemove = new string[](2);
        tagsToRemove[0] = "Tag1";
        tagsToRemove[1] = "Tag2";
        taggedList.removeTagsFromRecord(hash, tagsToRemove);

        // Ensure both tags have been removed
        assert(!taggedList.hasTag(hash, "Tag1"));
        assert(!taggedList.hasTag(hash, "Tag2"));
    }

    function testRepeatedOperations() public {
        bytes32 hash = _createSampleRecord();

        // Add a single tag using the single tag API
        taggedList.addTagToRecord(hash, "Tag1");
        assert(taggedList.hasTag(hash, "Tag1"));

        // Expect a revert when trying to add an existing tag using the single tag API
        vm.expectRevert("Tag already exists for the record");
        taggedList.addTagToRecord(hash, "Tag1");

        // This tag was never added. Use the single tag API to try and remove it.
        vm.expectRevert("Tag doesn't exist for the record");
        taggedList.removeTagFromRecord(hash, "Tag3");
    }

    function testInteractionsWithListFunctions() public {
        bytes32 hash = _createSampleRecord();

        // Add a single tag using the single tag API
        taggedList.addTagToRecord(hash, "Tag1");
        assert(taggedList.hasTag(hash, "Tag1"));

        // Soft delete the record
        taggedList.deleteRecord(hash);

        // Ensure we can still fetch the tag
        assert(taggedList.hasTag(hash, "Tag1"));
    }
}
