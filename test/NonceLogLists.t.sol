// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {DeletableListEntry} from "../src/ArrayLists.sol";
import {NonceLogLists} from "../src/NonceLogLists.sol";
import {ListRecord} from "../src/ListRecord.sol";

contract NonceLogListsTest is Test {
    NonceLogLists public nonceLogLists;
    uint constant NONCE = 123456789;
    uint8 constant VERSION = 1;
    uint8 constant RAW_ADDRESS = 1;

    function setUp() public {
        nonceLogLists = new NonceLogLists();
    }

    function test_ListManagerDefaultsToZeroAddress() public {
        address listManager = nonceLogLists.getListManager(NONCE);
        assertEq(listManager, address(0));
    }

    function test_CanClaimListManager() public {
        nonceLogLists.claimListManager(NONCE);
        address listManagerAfter = nonceLogLists.getListManager(NONCE);
        assertEq(listManagerAfter, address(this));
    }

    function test_CanClaimListManagerAndSetManager() public {
        nonceLogLists.claimListManager(NONCE);
        address listManagerAfter = nonceLogLists.getListManager(NONCE);
        assertEq(listManagerAfter, address(this));

        nonceLogLists.setListManager(NONCE, address(123));
        address listManagerAfter2 = nonceLogLists.getListManager(NONCE);
        assertEq(listManagerAfter2, address(123));
    }

    function test_CanClaimThenAppendRecord() public {
        nonceLogLists.claimListManager(NONCE);
        nonceLogLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
    }

    function test_RevertIf_NotListManager() public {
        vm.expectRevert("Not manager");
        nonceLogLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
    }

    function test_CanClaimThenDeleteRecord() public {
        nonceLogLists.claimListManager(NONCE);

        nonceLogLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        bytes32 hash = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xAbc123")));

        nonceLogLists.deleteRecord(NONCE, hash);
    }

    // Helper function to compare bytes
    function assertBytesEqual(bytes memory a, bytes memory b) internal pure {
        assert(a.length == b.length);
        for (uint i = 0; i < a.length; i++) {
            assert(a[i] == b[i]);
        }
    }
}
