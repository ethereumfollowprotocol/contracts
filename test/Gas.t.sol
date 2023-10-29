// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {DeletableListEntry} from "../src/ArrayLists.sol";
import {NonceArrayLists} from "../src/NonceArrayLists.sol";
import {NonceLogLists} from "../src/NonceLogLists.sol";
import {ListRecord} from "../src/ListRecord.sol";

contract NonceLogListsTest is Test {
    NonceArrayLists public nonceArrayLists;
    NonceLogLists public nonceLogLists;
    uint constant NONCE = 123456789;
    uint8 constant VERSION = 1;
    uint8 constant RAW_ADDRESS = 1;

    function setUp() public {
        nonceArrayLists = new NonceArrayLists();
        nonceArrayLists.claimListManager(NONCE);

        nonceLogLists = new NonceLogLists();
        nonceLogLists.claimListManager(NONCE);
    }

    function test_gasNonceArrayListsAppendRecord() public {
        nonceArrayLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
    }

    function test_gasNonceLogListsAppendRecord() public {
        nonceLogLists.appendRecord(NONCE, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
    }
}