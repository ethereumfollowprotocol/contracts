// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {NonceMappingLists} from "../src/NonceMappingLists.sol";
import {ListRecord} from "../src/ListRecord.sol";

contract NonceMappingListsTest is Test {
    NonceMappingLists public nonceMappingLists;
    uint constant NONCE = 123456789;
    uint8 constant VERSION = 1;
    uint8 constant LIST_RECORD_TYPE_RAW_ADDRESS = 1;
    address ADDRESS_1 = 0x0000000000000000000000000000000000AbC123;
    address ADDRESS_2 = 0x0000000000000000000000000000000000DeF456;
    bytes32 HASH_1 = keccak256(abi.encode(VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1)));
    bytes32 HASH_2 = keccak256(abi.encode(VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_2)));

    function setUp() public {
        nonceMappingLists = new NonceMappingLists();
    }

    function test_ListManagerDefaultsToZeroAddress() public {
        address listManager = nonceMappingLists.getListManager(NONCE);
        assertEq(listManager, address(0));
    }

    function test_CanClaimListManager() public {
        nonceMappingLists.claimListManager(NONCE);
        address listManagerAfter = nonceMappingLists.getListManager(NONCE);
        assertEq(listManagerAfter, address(this));
    }

    function test_CanClaimListManagerAndSetManager() public {
        nonceMappingLists.claimListManager(NONCE);
        address listManagerAfter = nonceMappingLists.getListManager(NONCE);
        assertEq(listManagerAfter, address(this));

        nonceMappingLists.setListManager(NONCE, address(123));
        address listManagerAfter2 = nonceMappingLists.getListManager(NONCE);
        assertEq(listManagerAfter2, address(123));
    }

    function test_CanClaimThenAppendRecord() public {
        nonceMappingLists.claimListManager(NONCE);

        assertEq(nonceMappingLists.hasRecord(NONCE, HASH_1), false);

        nonceMappingLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));

        assertEq(nonceMappingLists.hasRecord(NONCE, HASH_1), true);
    }

    function test_RevertIf_NotListManager() public {
        vm.expectRevert("Not manager");
        nonceMappingLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
    }

    function test_CanClaimThenAppendRecordThenDeleteRecord() public {
        nonceMappingLists.claimListManager(NONCE);

        assertEq(nonceMappingLists.hasRecord(NONCE, HASH_1), false);
        assertEq(nonceMappingLists.hasRecord(NONCE, HASH_2), false);

        nonceMappingLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
        assertEq(nonceMappingLists.hasRecord(NONCE, HASH_1), true);
        assertEq(nonceMappingLists.hasRecord(NONCE, HASH_2), false);

        nonceMappingLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_2));
        assertEq(nonceMappingLists.hasRecord(NONCE, HASH_1), true);
        assertEq(nonceMappingLists.hasRecord(NONCE, HASH_2), true);

        nonceMappingLists.deleteRecord(NONCE, HASH_1);
        assertEq(nonceMappingLists.hasRecord(NONCE, HASH_1), false);
        assertEq(nonceMappingLists.hasRecord(NONCE, HASH_2), true);
    }

    // Helper function to compare bytes
    function assertBytesEqual(bytes memory a, bytes memory b) internal pure {
        assert(a.length == b.length);
        for (uint i = 0; i < a.length; i++) {
            assert(a[i] == b[i]);
        }
    }
}
