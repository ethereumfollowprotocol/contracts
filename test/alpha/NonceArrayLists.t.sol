// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {DeletableListEntry} from "../../src/alpha/ArrayLists.sol";
import {NonceArrayLists} from "../../src/alpha/NonceArrayLists.sol";
import {ListRecord} from "../../src/alpha/ListRecord.sol";

contract NonceArrayListsTest is Test {
    NonceArrayLists public nonceArrayLists;
    uint constant NONCE = 123456789;
    uint8 constant VERSION = 1;
    uint8 constant LIST_RECORD_TYPE_RAW_ADDRESS = 1;
    address ADDRESS_1 = 0x0000000000000000000000000000000000AbC123;
    address ADDRESS_2 = 0x0000000000000000000000000000000000DeF456;
    address ADDRESS_3 = 0x0000000000000000000000000000000000789AbC;

    function setUp() public {
        nonceArrayLists = new NonceArrayLists();
    }

    function test_ListManagerDefaultsToZeroAddress() public {
        address listManager = nonceArrayLists.getListManager(NONCE);
        assertEq(listManager, address(0));
    }

    function test_CanClaimListManager() public {
        nonceArrayLists.claimListManager(NONCE);
        address listManagerAfter = nonceArrayLists.getListManager(NONCE);
        assertEq(listManagerAfter, address(this));
    }

    function test_CanClaimListManagerAndSetManager() public {
        nonceArrayLists.claimListManager(NONCE);
        address listManagerAfter = nonceArrayLists.getListManager(NONCE);
        assertEq(listManagerAfter, address(this));

        nonceArrayLists.setListManager(NONCE, address(123));
        address listManagerAfter2 = nonceArrayLists.getListManager(NONCE);
        assertEq(listManagerAfter2, address(123));
    }

    function test_CanClaimThenAppendRecord() public {
        nonceArrayLists.claimListManager(NONCE);

        assertEq(nonceArrayLists.getRecordCount(NONCE), 0);

        nonceArrayLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));

        assertEq(nonceArrayLists.getRecordCount(NONCE), 1);

        DeletableListEntry memory entry = nonceArrayLists.getRecord(NONCE, 0);
        assertEq(entry.deleted, false);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, LIST_RECORD_TYPE_RAW_ADDRESS);
        assertBytesEqual(entry.record.data, abi.encodePacked(ADDRESS_1));
    }

    function test_RevertIf_NotListManager() public {
        vm.expectRevert("Not manager");
        nonceArrayLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
    }

    function test_CanClaimThenAppendRecordThenDeleteRecord() public {
        nonceArrayLists.claimListManager(NONCE);

        nonceArrayLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
        bytes32 hash = keccak256(abi.encode(VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1)));

        nonceArrayLists.deleteRecord(NONCE, hash);

        assertEq(nonceArrayLists.getRecordCount(NONCE), 1);

        DeletableListEntry memory entry = nonceArrayLists.getRecord(NONCE, 0);
        assertEq(entry.deleted, true);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, LIST_RECORD_TYPE_RAW_ADDRESS);
        assertBytesEqual(entry.record.data, abi.encodePacked(ADDRESS_1));
    }

    function test_CanClaimThenAppendRecordThenDeleteRecordThenAppendRecordAgain() public {
        nonceArrayLists.claimListManager(NONCE);

        nonceArrayLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
        assertEq(nonceArrayLists.getRecordCount(NONCE), 1);

        bytes32 hash = keccak256(abi.encode(VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1)));

        nonceArrayLists.deleteRecord(NONCE, hash);
        assertEq(nonceArrayLists.getRecordCount(NONCE), 1);

        DeletableListEntry memory entry0 = nonceArrayLists.getRecord(NONCE, 0);
        assertEq(entry0.deleted, true);
        assertEq(entry0.record.version, VERSION);
        assertEq(entry0.record.recordType, LIST_RECORD_TYPE_RAW_ADDRESS);
        assertBytesEqual(entry0.record.data, abi.encodePacked(ADDRESS_1));

        nonceArrayLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
        assertEq(nonceArrayLists.getRecordCount(NONCE), 2);

        DeletableListEntry memory entry1 = nonceArrayLists.getRecord(NONCE, 1);
        assertEq(entry1.deleted, false);
        assertEq(entry1.record.version, VERSION);
        assertEq(entry1.record.recordType, LIST_RECORD_TYPE_RAW_ADDRESS);
        assertBytesEqual(entry1.record.data, abi.encodePacked(ADDRESS_1));
    }

    function test_CanClaimThenGetRecordsInRange() public {
        nonceArrayLists.claimListManager(NONCE);

        nonceArrayLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
        nonceArrayLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_2));
        nonceArrayLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_3));

        DeletableListEntry[] memory entries = nonceArrayLists.getRecordsInRange(NONCE, 1, 2);

        assertEq(entries.length, 2);
        assertBytesEqual(entries[0].record.data, abi.encodePacked(ADDRESS_2));
        assertBytesEqual(entries[1].record.data, abi.encodePacked(ADDRESS_3));
    }

    // Helper function to compare bytes
    function assertBytesEqual(bytes memory a, bytes memory b) internal pure {
        assert(a.length == b.length);
        for (uint i = 0; i < a.length; i++) {
            assert(a[i] == b[i]);
        }
    }
}
