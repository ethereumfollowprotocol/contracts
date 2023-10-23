// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {DeletableListEntry} from "../src/BaseLists.sol";
import {Lists} from "../src/Lists.sol";
import {ListRecord} from "../src/ListRecord.sol";
import {ListRegistry} from "../src/ListRegistry.sol";

contract ListsTest is Test {
    ListRegistry public listRegistry;
    Lists public lists;
    uint8 constant VERSION = 1;
    uint8 constant RAW_ADDRESS = 1;
    uint constant TOKEN_ID = 0;

    function setUp() public {
        listRegistry = new ListRegistry();
        lists = new Lists(listRegistry);
        listRegistry.mint();
    }

    function test_CanAppendRecord() public {
        assertEq(lists.getRecordCount(TOKEN_ID), 0);

        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));

        assertEq(lists.getRecordCount(TOKEN_ID), 1);

        DeletableListEntry memory entry = lists.getRecord(TOKEN_ID, 0);
        assertEq(entry.deleted, false);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xAbc123"));
    }

    function test_CannotAppendSameRecordTwice() public {
        assertEq(lists.getRecordCount(TOKEN_ID), 0);

        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));

        assertEq(lists.getRecordCount(TOKEN_ID), 1);

        DeletableListEntry memory entry = lists.getRecord(TOKEN_ID, 0);
        assertEq(entry.deleted, false);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xAbc123"));

        // append same record again
        vm.expectRevert("Record already exists!");
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
    }

    function test_CanAppendRecords() public {
        assertEq(lists.getRecordCount(TOKEN_ID), 0);

        ListRecord[] memory records = new ListRecord[](2);
        records[0] = ListRecord(VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        records[1] = ListRecord(VERSION, RAW_ADDRESS, bytes("0xDef456"));

        lists.appendRecords(TOKEN_ID, records);

        assertEq(lists.getRecordCount(TOKEN_ID), 2);

        DeletableListEntry memory entry = lists.getRecord(TOKEN_ID, 0);
        assertEq(entry.deleted, false);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xAbc123"));

        entry = lists.getRecord(TOKEN_ID, 1);
        assertEq(entry.deleted, false);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xDef456"));
    }

    function test_CanDeleteRecord() public {
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        bytes32 hash = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xAbc123")));

        lists.deleteRecord(TOKEN_ID, hash);

        assertEq(lists.getRecordCount(TOKEN_ID), 1);

        DeletableListEntry memory entry = lists.getRecord(TOKEN_ID, 0);
        assertEq(entry.deleted, true);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xAbc123"));
    }

    function test_CannotDeleteSameRecordTwice() public {
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        bytes32 hash = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xAbc123")));

        lists.deleteRecord(TOKEN_ID, hash);

        assertEq(lists.getRecordCount(TOKEN_ID), 1);

        DeletableListEntry memory entry = lists.getRecord(TOKEN_ID, 0);
        assertEq(entry.deleted, true);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xAbc123"));

        vm.expectRevert("Record not found");
        lists.deleteRecord(TOKEN_ID, hash);
    }

    function test_CannotDeleteMissingRecord() public {
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        bytes32 hash = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xDef456")));

        vm.expectRevert("Record not found");
        lists.deleteRecord(TOKEN_ID, hash);
    }

    function test_CanDeleteRecordThenAppendAgain() public {
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        bytes32 hash = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xAbc123")));

        lists.deleteRecord(TOKEN_ID, hash);

        assertEq(lists.getRecordCount(TOKEN_ID), 1);

        DeletableListEntry memory entry = lists.getRecord(TOKEN_ID, 0);
        assertEq(entry.deleted, true);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xAbc123"));

        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xDef456"));

        assertEq(lists.getRecordCount(TOKEN_ID), 2);

        entry = lists.getRecord(TOKEN_ID, 0);
        assertEq(entry.deleted, true);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xAbc123"));

        entry = lists.getRecord(TOKEN_ID, 1);
        assertEq(entry.deleted, false);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xDef456"));
    }

    function test_CanDeleteRecords() public {
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xDef456"));
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xGhi789"));

        bytes32[] memory hashes = new bytes32[](2);
        hashes[0] = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xAbc123")));
        hashes[1] = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xDef456")));

        lists.deleteRecords(TOKEN_ID, hashes);

        assertEq(lists.getRecordCount(TOKEN_ID), 3);

        DeletableListEntry memory entry = lists.getRecord(TOKEN_ID, 0);
        assertEq(entry.deleted, true);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xAbc123"));

        entry = lists.getRecord(TOKEN_ID, 1);
        assertEq(entry.deleted, true);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xDef456"));

        entry = lists.getRecord(TOKEN_ID, 2);
        assertEq(entry.deleted, false);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xGhi789"));
    }

    function test_CanGetRecordsInRange() public {
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xDef456"));
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xGhi789"));

        DeletableListEntry[] memory entries = lists.getRecordsInRange(TOKEN_ID, 1, 2);

        assertEq(entries.length, 2);
        assertEq(entries[0].deleted, false);
        assertBytesEqual(entries[0].record.data, bytes("0xDef456"));
        assertEq(entries[1].deleted, false);
        assertBytesEqual(entries[1].record.data, bytes("0xGhi789"));
    }

    function test_CanGetRecordsInRangeIncludingDeletions() public {
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xDef456"));
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xGhi789"));
        // delete one of the records
        bytes32 hash = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xDef456")));
        lists.deleteRecord(TOKEN_ID, hash);

        DeletableListEntry[] memory entries = lists.getRecordsInRange(TOKEN_ID, 1, 2);

        assertEq(entries.length, 2);
        assertEq(entries[0].deleted, true);
        assertBytesEqual(entries[0].record.data, bytes("0xDef456"));
        assertEq(entries[1].deleted, false);
        assertBytesEqual(entries[1].record.data, bytes("0xGhi789"));
    }

    // Helper function to compare bytes
    function assertBytesEqual(bytes memory a, bytes memory b) internal pure {
        assert(a.length == b.length);
        for (uint i = 0; i < a.length; i++) {
            assert(a[i] == b[i]);
        }
    }
}
