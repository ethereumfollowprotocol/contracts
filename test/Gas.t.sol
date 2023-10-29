// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {DeletableListEntry} from "../src/ArrayLists.sol";
import {NonceArrayLists} from "../src/NonceArrayLists.sol";
import {NonceLogLists} from "../src/NonceLogLists.sol";
import {NonceMappingLists} from "../src/NonceMappingLists.sol";
import {ListRecord} from "../src/ListRecord.sol";

contract NonceLogListsTest is Test {
    NonceArrayLists public nonceArrayLists;
    NonceLogLists public nonceLogLists;
    NonceMappingLists public nonceMappingLists;
    uint constant NONCE = 123456789;
    uint8 constant VERSION = 1;
    uint8 constant LIST_RECORD_TYPE_RAW_ADDRESS = 1;
    address ADDRESS_1 = 0x0000000000000000000000000000000000AbC123;
    address ADDRESS_2 = 0x0000000000000000000000000000000000DeF456;
    address ADDRESS_3 = 0x0000000000000000000000000000000000789AbC;

    function setUp() public {
        nonceArrayLists = new NonceArrayLists();
        nonceArrayLists.claimListManager(NONCE);

        nonceLogLists = new NonceLogLists();
        nonceLogLists.claimListManager(NONCE);

        nonceMappingLists = new NonceMappingLists();
        nonceMappingLists.claimListManager(NONCE);
    }

    function test_gasNonceArrayListsAppendRecord() public {
        nonceArrayLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
    }

    function test_gasNonceLogListsAppendRecord() public {
        nonceLogLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
    }

    function test_gasNonceMappingListsAppendRecord() public {
        nonceMappingLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
    }
}