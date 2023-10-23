// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Tags.sol";
import {ListRegistry} from "../src/ListRegistry.sol";

contract TagsTest is Test {
    ListRegistry public listRegistry;
    Tags public tags;
    uint8 constant VERSION = 1;
    uint8 constant RAW_ADDRESS = 1;
    uint constant TOKEN_ID = 0;

    function setUp() public {
        listRegistry = new ListRegistry();
        tags = new Tags(listRegistry);
        listRegistry.mint();
    }

    function _createAndAppendSampleRecord() internal returns (bytes32) {
        // Append a record
        tags.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));

        // Get the hash of the record to use as an identifier
        bytes32 hash = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xAbc123")));
        return hash;
    }

    ///////////////////////////////////////////////////////////////////////////
    // Add
    ///////////////////////////////////////////////////////////////////////////

    function test_CanAddTagToRecord() public {
        bytes32 hash = _createAndAppendSampleRecord();

        // Check that the record doesn't initially have the tag
        assert(!tags.hasTag(TOKEN_ID, hash, "Tag1"));

        // Add a tag to the record using the single tag API
        tags.addTagToRecord(TOKEN_ID, hash, "Tag1");

        // Now check that the record has the tag
        assert(tags.hasTag(TOKEN_ID, hash, "Tag1"));
    }

    function test_CanAddMultipleTagsToRecord() public {
        bytes32 hash = _createAndAppendSampleRecord();

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
        tags.deleteTagsFromRecord(TOKEN_ID, hash, tagsToRemove);

        // Ensure both tags have been deleted
        assert(!tags.hasTag(TOKEN_ID, hash, "Tag1"));
        assert(!tags.hasTag(TOKEN_ID, hash, "Tag2"));
    }

    function test_RevertIf_AddDuplicateTagToRecord() public {
        bytes32 hash = _createAndAppendSampleRecord();

        // Add a single tag using the single tag API
        tags.addTagToRecord(TOKEN_ID, hash, "Tag1");
        assert(tags.hasTag(TOKEN_ID, hash, "Tag1"));

        // Expect a revert when trying to add an existing tag using the single tag API
        vm.expectRevert("Tag already exists for the record");
        tags.addTagToRecord(TOKEN_ID, hash, "Tag1");
    }

    ///////////////////////////////////////////////////////////////////////////
    // Remove
    ///////////////////////////////////////////////////////////////////////////

    function test_CanRemoveTagFromRecord() public {
        bytes32 hash = _createAndAppendSampleRecord();

        // Add a tag to the record using the single tag API
        tags.addTagToRecord(TOKEN_ID, hash, "Tag1");
        assert(tags.hasTag(TOKEN_ID, hash, "Tag1"));

        // Remove the tag from the record using the single tag API
        tags.deleteTagFromRecord(TOKEN_ID, hash, "Tag1");

        // Check that the tag has been deleted
        assert(!tags.hasTag(TOKEN_ID, hash, "Tag1"));
    }

    function test_RevertIf_RemoveNonexistantTagFromRecord() public {
        bytes32 hash = _createAndAppendSampleRecord();

        // This tag was never added. Use the single tag API to try and delete it.
        vm.expectRevert("Tag doesn't exist for the record");
        tags.deleteTagFromRecord(TOKEN_ID, hash, "Tag3");
    }

    function test_TagPersistsAfterRecordDeleted() public {
        bytes32 hash = _createAndAppendSampleRecord();

        // Add a single tag using the single tag API
        tags.addTagToRecord(TOKEN_ID, hash, "Tag1");
        assert(tags.hasTag(TOKEN_ID, hash, "Tag1"));

        // Soft delete the record
        tags.deleteRecord(TOKEN_ID, hash);

        // Ensure we can still fetch the tag
        assert(tags.hasTag(TOKEN_ID, hash, "Tag1"));
    }

    function test_CanDeleteTagAfterRecordDeleted() public {
        bytes32 hash = _createAndAppendSampleRecord();

        // Add a single tag using the single tag API
        tags.addTagToRecord(TOKEN_ID, hash, "Tag1");
        assert(tags.hasTag(TOKEN_ID, hash, "Tag1"));

        // Soft delete the record
        tags.deleteRecord(TOKEN_ID, hash);

        // tag should still persist
        assert(tags.hasTag(TOKEN_ID, hash, "Tag1"));

        // Ensure we can still delete the tag
        tags.deleteTagFromRecord(TOKEN_ID, hash, "Tag1");
        assert(!tags.hasTag(TOKEN_ID, hash, "Tag1"));
    }

    ///////////////////////////////////////////////////////////////////////////
    // Modify
    ///////////////////////////////////////////////////////////////////////////

    function test_ModifyAddTagToExistingRecord() public {
        bytes32 hash = _createAndAppendSampleRecord();

        // Ensure that the record doesn't initially have the tag
        assert(!tags.hasTag(TOKEN_ID, hash, "TestTag"));

        // Create a modification operation to append the tag
        ListOperation memory operation;
        operation.operationType = tags.OPERATION_ADD_TAG();
        operation.data = abi.encode(hash, "TestTag"); // Encoding recordHash and tag

        // Modify the record by appending the tag
        tags.modifyRecord(TOKEN_ID, operation);

        // Now check that the record has the tag
        assert(tags.hasTag(TOKEN_ID, hash, "TestTag"));
    }

    function test_ModifyAppendRecordThenTag() public {
        // Create the ListRecord data for appending
        ListRecord memory record = ListRecord(VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        bytes32 hash = keccak256(abi.encode(record.version, record.recordType, record.data));
        // Perform both operations in sequence
        ListOperation[] memory operations = new ListOperation[](2);
        operations[0] =  ListOperation(tags.OPERATION_APPEND(), abi.encode(record));
        operations[1] = ListOperation(tags.OPERATION_ADD_TAG(), abi.encode(hash, "TestTag"));
        tags.modifyRecords(TOKEN_ID, operations);

        // Check if the record has been appended
        assertEq(tags.getRecordCount(TOKEN_ID), 1);
        // Check if the tag has been appended to the record
        assert(tags.hasTag(TOKEN_ID, hash, "TestTag"));
    }

    function test_ModifyAppendRecordThenMultipleTags() public {
        // Create the ListRecord data for appending
        ListRecord memory record = ListRecord(VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        bytes32 hash = keccak256(abi.encode(record.version, record.recordType, record.data));
        // Perform both operations in sequence
        ListOperation[] memory operations = new ListOperation[](3);
        operations[0] =  ListOperation(tags.OPERATION_APPEND(), abi.encode(record));
        operations[1] = ListOperation(tags.OPERATION_ADD_TAG(), abi.encode(hash, "TestTag"));
        operations[2] = ListOperation(tags.OPERATION_ADD_TAG(), abi.encode(hash, "TestTag2"));
        tags.modifyRecords(TOKEN_ID, operations);

        // Check if the record has been appended
        assertEq(tags.getRecordCount(TOKEN_ID), 1);
        // Check if the tag has been appended to the record
        assert(tags.hasTag(TOKEN_ID, hash, "TestTag"));
        assert(tags.hasTag(TOKEN_ID, hash, "TestTag2"));
    }

}
