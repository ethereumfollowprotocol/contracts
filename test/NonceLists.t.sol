// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {DeletableListEntry} from "../src/BaseLists.sol";
import {NonceLists} from "../src/NonceLists.sol";
import {ListRecord} from "../src/ListRecord.sol";

contract NonceListsTest is Test {
    NonceLists public nonceLists;
    uint constant NONCE = 123456789;
    uint8 constant VERSION = 1;
    uint8 constant RAW_ADDRESS = 1;

    function setUp() public {
        nonceLists = new NonceLists();
    }

    function test_ListManagerDefaultsToZeroAddress() public {
        address listManager = nonceLists.getListManager(NONCE);
        assertEq(listManager, address(0));
    }

    function test_CanClaimListManager() public {
        nonceLists.claimListManager(NONCE);
        address listManagerAfter = nonceLists.getListManager(NONCE);
        assertEq(listManagerAfter, address(this));
    }

    function test_CanClaimListManagerAndSetManager() public {
        nonceLists.claimListManager(NONCE);
        address listManagerAfter = nonceLists.getListManager(NONCE);
        assertEq(listManagerAfter, address(this));

        nonceLists.setListManager(NONCE, address(123));
        address listManagerAfter2 = nonceLists.getListManager(NONCE);
        assertEq(listManagerAfter2, address(123));
    }

    function test_CanClaimThenAppendRecord() public {
        nonceLists.claimListManager(NONCE);

        assertEq(nonceLists.getRecordCount(NONCE), 0);

        nonceLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xAbc123"));

        assertEq(nonceLists.getRecordCount(NONCE), 1);

        DeletableListEntry memory entry = nonceLists.getRecord(NONCE, 0);
        assertEq(entry.deleted, false);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xAbc123"));
    }

    function test_RevertIf_NotListManager() public {
        vm.expectRevert("Not manager");
        nonceLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
    }

    function test_CanClaimThenDeleteRecord() public {
        nonceLists.claimListManager(NONCE);

        nonceLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        bytes32 hash = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xAbc123")));

        nonceLists.deleteRecord(NONCE, hash);

        assertEq(nonceLists.getRecordCount(NONCE), 1);

        DeletableListEntry memory entry = nonceLists.getRecord(NONCE, 0);
        assertEq(entry.deleted, true);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xAbc123"));
    }

    function test_CanClaimThenGetRecordsInRange() public {
        nonceLists.claimListManager(NONCE);

        nonceLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        nonceLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xDef456"));
        nonceLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xGhi789"));

        DeletableListEntry[] memory entries = nonceLists.getRecordsInRange(NONCE, 1, 2);

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
