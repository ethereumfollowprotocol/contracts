// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {ListOpStore} from "../../src/beta/ListOpStore.sol";
import {ListOp} from "../../src/beta/ListOp.sol";
import {ListRecord} from "../../src/beta/ListRecord.sol";
import {ListRegistry} from "../../src/beta/ListRegistry.sol";

contract ListsTest is Test {
    ListRegistry public listRegistry;
    ListOpStore public listOpStore;
    uint8 constant LIST_OP_VERSION = 1;
    uint8 constant LIST_OP_TYPE_ADD_RECORD = 1;
    uint8 constant LIST_RECORD_VERSION = 1;
    uint8 constant LIST_RECORD_TYPE_RAW_ADDRESS = 1;
    address ADDRESS_1 = 0x0000000000000000000000000000000000AbC123;
    address ADDRESS_2 = 0x0000000000000000000000000000000000DeF456;
    address ADDRESS_3 = 0x0000000000000000000000000000000000789AbC;
    uint constant TOKEN_ID = 0;

    function setUp() public {
        listRegistry = new ListRegistry();
        listOpStore = new ListOpStore();
        listRegistry.mint();
    }

    function test_CanClaimListManager() public {
        vm.prank(ADDRESS_1);
        listOpStore.claimListManager(TOKEN_ID);

        assertEq(listOpStore.getListManager(TOKEN_ID), ADDRESS_1, "Manager1 should be the manager of list 1");
    }

    function test_CanSetListManager() public {
        vm.prank(ADDRESS_1);
        listOpStore.claimListManager(TOKEN_ID);

        vm.prank(ADDRESS_1);
        listOpStore.setListManager(TOKEN_ID, ADDRESS_2);

        assertEq(listOpStore.getListManager(TOKEN_ID), ADDRESS_2, "Manager2 should now be the manager of list 1");
    }

    function test_CanApplyListOpToAddRecord() public {
        assertEq(listOpStore.getListOpCount(TOKEN_ID), 0);

        listOpStore.claimListManager(TOKEN_ID);

        bytes memory listOp = abi.encodePacked(
            LIST_OP_VERSION,                 // Version for ListOp
            LIST_OP_TYPE_ADD_RECORD,         // Operation type for ListOp (Add Record)
            LIST_RECORD_VERSION,             // Version for ListRecord
            LIST_RECORD_TYPE_RAW_ADDRESS,    // Record type for ListRecord (Raw Address)
            ADDRESS_1                        // Raw address (20 bytes)
        );

        listOpStore.applyListOp(TOKEN_ID, listOp);

        assertEq(listOpStore.getListOpCount(TOKEN_ID), 1);
        assertBytesEqual(listOpStore.getListOp(TOKEN_ID, 0), listOp);
    }

    // Helper function to compare bytes
    function assertBytesEqual(bytes memory a, bytes memory b) internal pure {
        assert(a.length == b.length);
        for (uint i = 0; i < a.length; i++) {
            assert(a[i] == b[i]);
        }
    }
}
