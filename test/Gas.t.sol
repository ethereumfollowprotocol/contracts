// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {DeletableListEntry} from "../src/ArrayLists.sol";
import {NonceArrayLists} from "../src/NonceArrayLists.sol";
import {NonceLogLists} from "../src/NonceLogLists.sol";
import {NonceMappingLists} from "../src/NonceMappingLists.sol";
import {ListOperation} from "../src/ListOperation.sol";
import {ListRecord} from "../src/ListRecord.sol";

contract NonceLogListsTest is Test {
    NonceArrayLists public nonceArrayLists;
    NonceLogLists public nonceLogLists;
    NonceMappingLists public nonceMappingLists;
    uint constant NONCE = 123456789;
    uint8 constant VERSION = 1;
    uint8 constant LIST_RECORD_TYPE_RAW_ADDRESS = 1;
    address ADDRESS_1 = 0x0000000000000000000000000000000000AbC123;

    address[100] public addresses;

    ListOperation[] public operations10;
    ListOperation[] public operations100;

    function setUp() public {
        nonceArrayLists = new NonceArrayLists();
        nonceArrayLists.claimListManager(NONCE);

        nonceLogLists = new NonceLogLists();
        nonceLogLists.claimListManager(NONCE);

        nonceMappingLists = new NonceMappingLists();
        nonceMappingLists.claimListManager(NONCE);

        // Generate dummy addresses for testing
        for(uint i = 0; i < 100; i++) {
            addresses[i] = address(uint160(i));
        }

        ListOperation[] memory _operations10 = _generateOperations(10);
        for (uint i = 0; i < _operations10.length; i++) {
            operations10.push(_operations10[i]);
        }
        ListOperation[] memory _operations100 = _generateOperations(100);
        for (uint i = 0; i < _operations100.length; i++) {
            operations100.push(_operations100[i]);
        }
    }

    function _generateOperations(uint count) internal view returns (ListOperation[] memory ops) {
        require(count <= 100, "Cannot generate more than 100 operations");

        ops = new ListOperation[](count);
        for(uint i = 0; i < count; i++) {
            address addr = address(uint160(i)); // Generate a dummy address based on the loop index
            ops[i] = ListOperation({
                operationType: nonceArrayLists.OPERATION_APPEND(),
                data: abi.encode(ListRecord(VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(addr)))
            });
        }
    }


    function test_appendRecord_nonceArrayLists() public {
        nonceArrayLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
    }

    function test_appendRecord_nonceLogLists() public {
        nonceLogLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
    }

    function test_appendRecord_nonceMappingLists() public {
        nonceMappingLists.appendRecord(NONCE, VERSION, LIST_RECORD_TYPE_RAW_ADDRESS, abi.encodePacked(ADDRESS_1));
    }

    function test_modifyAppend10_nonceArrayLists() public {
        nonceArrayLists.modifyRecords(NONCE, operations10);
    }

    function test_modifyAppend10_nonceLogLists() public {
        nonceLogLists.modifyRecords(NONCE, operations10);
    }

    function test_modifyAppend10_nonceMappingLists() public {
        nonceMappingLists.modifyRecords(NONCE, operations10);
    }

    function test_modifyAppend100_nonceArrayLists() public {
        nonceArrayLists.modifyRecords(NONCE, operations100);
    }

    function test_modifyAppend100_nonceLogLists() public {
        nonceLogLists.modifyRecords(NONCE, operations100);
    }

    function test_modifyAppend100_nonceMappingLists() public {
        nonceMappingLists.modifyRecords(NONCE, operations100);
    }
}