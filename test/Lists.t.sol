// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
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
    }

    function testAppendRecord() public {
        listRegistry.mint();

        assertEq(lists.getRecordCount(TOKEN_ID), 0);

        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));

        assertEq(lists.getRecordCount(TOKEN_ID), 1);

        ListRecord memory record = lists.getRecord(TOKEN_ID, 0);
        assertEq(record.version, VERSION);
        assertEq(record.recordType, RAW_ADDRESS);
        assertBytesEqual(record.data, bytes("0xAbc123"));
    }

    function testDeleteRecord() public {
        listRegistry.mint();

        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        bytes32 hash = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xAbc123")));

        lists.deleteRecord(TOKEN_ID, hash);

        assertEq(lists.getRecordCount(TOKEN_ID), 1);

        ListRecord memory record = lists.getRecord(TOKEN_ID, 0);
        assertEq(record.version, VERSION);
        assertEq(record.recordType, RAW_ADDRESS);
        assertBytesEqual(record.data, bytes("0xAbc123"));
    }

    function testGetRecordsInRange() public {
        listRegistry.mint();

        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xDef456"));
        lists.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xGhi789"));

        ListRecord[] memory records = lists.getRecordsInRange(TOKEN_ID, 1, 2);

        assertEq(records.length, 2);
        assertBytesEqual(records[0].data, bytes("0xDef456"));
        assertBytesEqual(records[1].data, bytes("0xGhi789"));
    }

    // Helper function to compare bytes
    function assertBytesEqual(bytes memory a, bytes memory b) internal pure {
        assert(a.length == b.length);
        for (uint i = 0; i < a.length; i++) {
            assert(a[i] == b[i]);
        }
    }
}
