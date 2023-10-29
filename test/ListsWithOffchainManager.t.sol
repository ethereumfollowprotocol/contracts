// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {DeletableListEntry} from "../src/ArrayLists.sol";
import {ListsWithOffchainManager} from "../src/ListsWithOffchainManager.sol";
import {ListRecord} from "../src/ListRecord.sol";

contract ListsWithOffchainManagerTest is Test {
    ListsWithOffchainManager public listsWithOffchainManager;
    uint8 constant VERSION = 1;
    uint8 constant RAW_ADDRESS = 1;
    uint constant TOKEN_ID = 0;
    address constant SIGNER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    // offchain signature for nonce 0 and manager 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496
    address constant MANAGER = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496;
    bytes constant OFFCHAIN_SIGNATURE = hex"276e11588e9fb487eeab8bd4ce66075bbbd162f673dde0fde98947bae001b0506c100c6d7e1ea1d47107f63c302564ac1a2746de0aa0894fe597738cd03c15781c";

    function setUp() public {
        listsWithOffchainManager = new ListsWithOffchainManager(SIGNER);
        // ensure hard-coded test constants match the contract address
        assertEq(MANAGER, address(this));
    }

    function testClaimListManagerWithOffchainSignature() public {
        address offchainSigner = listsWithOffchainManager.getSigner();
        assertEq(offchainSigner, SIGNER);

        address listManagerBefore = listsWithOffchainManager.getListManager(TOKEN_ID);
        assertEq(listManagerBefore, address(0));

        listsWithOffchainManager.claimListManagerWithOffchainSignature(TOKEN_ID, OFFCHAIN_SIGNATURE);
        address listManagerAfter = listsWithOffchainManager.getListManager(TOKEN_ID);
        assertEq(listManagerAfter, address(this));
    }

    function testAppendRecord() public {
        listsWithOffchainManager.claimListManagerWithOffchainSignature(TOKEN_ID, OFFCHAIN_SIGNATURE);

        assertEq(listsWithOffchainManager.getRecordCount(TOKEN_ID), 0);

        listsWithOffchainManager.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));

        assertEq(listsWithOffchainManager.getRecordCount(TOKEN_ID), 1);

        DeletableListEntry memory entry = listsWithOffchainManager.getRecord(TOKEN_ID, 0);
        assertEq(entry.deleted, false);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xAbc123"));
    }

    function testDeleteRecord() public {
        listsWithOffchainManager.claimListManagerWithOffchainSignature(TOKEN_ID, OFFCHAIN_SIGNATURE);

        listsWithOffchainManager.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        bytes32 hash = keccak256(abi.encode(VERSION, RAW_ADDRESS, bytes("0xAbc123")));

        assertEq(listsWithOffchainManager.getRecordCount(TOKEN_ID), 1);

        listsWithOffchainManager.deleteRecord(TOKEN_ID, hash);

        assertEq(listsWithOffchainManager.getRecordCount(TOKEN_ID), 1);

        DeletableListEntry memory entry = listsWithOffchainManager.getRecord(TOKEN_ID, 0);
        assertEq(entry.deleted, true);
        assertEq(entry.record.version, VERSION);
        assertEq(entry.record.recordType, RAW_ADDRESS);
        assertBytesEqual(entry.record.data, bytes("0xAbc123"));
    }

    function testGetRecordsInRange() public {
        listsWithOffchainManager.claimListManagerWithOffchainSignature(TOKEN_ID, OFFCHAIN_SIGNATURE);

        listsWithOffchainManager.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xAbc123"));
        listsWithOffchainManager.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xDef456"));
        listsWithOffchainManager.appendRecord(TOKEN_ID, VERSION, RAW_ADDRESS, bytes("0xGhi789"));

        DeletableListEntry[] memory entries = listsWithOffchainManager.getRecordsInRange(TOKEN_ID, 1, 2);

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
