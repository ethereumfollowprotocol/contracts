// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {DeletableListEntry} from "../src/ArrayLists.sol";
import {NonceArrayLists} from "../src/NonceArrayLists.sol";
import {ListRecord} from "../src/ListRecord.sol";

contract NonceArrayListsTest is Test {
    NonceArrayLists public nonceArrayLists;
    uint constant NONCE = 123456789;
    uint8 constant VERSION = 1;
    uint8 constant RAW_ADDRESS = 1;

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

        nonceArrayLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xAbc123"));

        assertEq(nonceArrayLists.getRecordCount(NONCE), 1);

        DeletableListEntry memory entry = nonceArrayLists.getRecord(NONCE, 0);
        assertEq(entry.deleted, false);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xAbc123"));
    }

    function test_RevertIf_NotListManager() public {
        vm.expectRevert("Not manager");
        nonceArrayLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
    }

    function test_CanClaimThenDeleteRecord() public {
        nonceArrayLists.claimListManager(NONCE);

        nonceArrayLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        bytes32 hash = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xAbc123")));

        nonceArrayLists.deleteRecord(NONCE, hash);

        assertEq(nonceArrayLists.getRecordCount(NONCE), 1);

        DeletableListEntry memory entry = nonceArrayLists.getRecord(NONCE, 0);
        assertEq(entry.deleted, true);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xAbc123"));
    }

    function test_CanClaimThenGetRecordsInRange() public {
        nonceArrayLists.claimListManager(NONCE);

        nonceArrayLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        nonceArrayLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xDef456"));
        nonceArrayLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xGhi789"));

        DeletableListEntry[] memory entries = nonceArrayLists.getRecordsInRange(NONCE, 1, 2);

        assertEq(entries.length, 2);
        assertBytesEqual(entries[0].record.data, bytes("0xDef456"));
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
