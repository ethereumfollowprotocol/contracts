// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/old/List.sol";

contract ListTest is Test {
    List public list;
    uint8 constant VERSION = 1;
    uint8 constant RAW_ADDRESS = 1;

    function setUp() public {
        list = new List();
    }

    function testAppendRecord() public {
        assertEq(list.getRecordCount(), 0);

        list.appendRecord(VERSION, RAW_ADDRESS, bytes("0xAbc123"));

        assertEq(list.getRecordCount(), 1);

        ListRecord memory record = list.getRecord(0);
        assertEq(record.version, VERSION);
        assertEq(record.recordType, RAW_ADDRESS);
        assertBytesEqual(record.data, bytes("0xAbc123"));
    }

    function testDeleteRecord() public {
        list.appendRecord(VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        bytes32 hash = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xAbc123")));

        list.deleteRecord(hash);

        // While the record is soft-deleted, the getRecordCount and getRecord functions would still return it
        assertEq(list.getRecordCount(), 1);

        ListRecord memory record = list.getRecord(0);
        assertEq(record.version, VERSION);
        assertEq(record.recordType, RAW_ADDRESS);
        assertBytesEqual(record.data, bytes("0xAbc123"));
        // Here, you might want an additional function in the main contract to check if a record is deleted or not
    }

    function testGetRecordsInRange() public {
        list.appendRecord(VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        list.appendRecord(VERSION, RAW_ADDRESS, bytes("0xDef456"));
        list.appendRecord(VERSION, RAW_ADDRESS, bytes("0xGhi789"));

        ListRecord[] memory records = list.getRecordsInRange(1, 2);

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
