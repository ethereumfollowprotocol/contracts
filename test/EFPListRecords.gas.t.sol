// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import 'forge-std/Test.sol';
import {EFPListRecords} from '../src/EFPListRecords.sol';

contract EFPListRecordsGasTest is Test {
  EFPListRecords public listRecords;
  uint8 constant LIST_OP_VERSION = 1;
  uint8 constant LIST_OP_TYPE_ADD_RECORD = 1;
  uint8 constant LIST_OP_TYPE_REMOVE_RECORD = 2;
  uint8 constant LIST_OP_TYPE_ADD_TAG = 3;
  uint8 constant LIST_OP_TYPE_REMOVE_TAG = 4;
  uint8 constant LIST_RECORD_VERSION = 1;
  uint8 constant LIST_RECORD_TYPE_RAW_ADDRESS = 1;
  address ADDRESS_1 = 0x0000000000000000000000000000000000AbC123;
  address ADDRESS_2 = 0x0000000000000000000000000000000000DeF456;
  address ADDRESS_3 = 0x0000000000000000000000000000000000789AbC;
  uint256 constant NONCE = 0x1234567890ABCDEF;

  bytes public listOp =
    abi.encodePacked(
      LIST_OP_VERSION, // Version for ListOp
      LIST_OP_TYPE_ADD_RECORD, // Operation type for ListOp (Add Record)
      LIST_RECORD_VERSION, // Version for ListRecord
      LIST_RECORD_TYPE_RAW_ADDRESS, // Record type for ListRecord (Raw Address)
      ADDRESS_1 // Raw address (20 bytes)
    );
  bytes[] public listOps__0001;
  bytes[] public listOps__0002;
  bytes[] public listOps__0003;
  bytes[] public listOps__0004;
  bytes[] public listOps__0005;
  bytes[] public listOps__0010;
  bytes[] public listOps__0020;
  bytes[] public listOps__0030;
  bytes[] public listOps__0040;
  bytes[] public listOps__0050;
  bytes[] public listOps__0100;
  bytes[] public listOps__0200;
  bytes[] public listOps__0300;
  bytes[] public listOps__0400;
  bytes[] public listOps__0500;
  bytes[] public listOps__1000;

  function setUp() public {
    listRecords = new EFPListRecords();
    // listRecords.claimListManager(NONCE);
    for (uint256 i = 0; i < 1000; i++) {
      bytes memory listOpBytes = encodeListOp(LIST_OP_TYPE_ADD_RECORD);
      if (i < 1) {
        listOps__0001.push(listOpBytes);
      }
      if (i < 2) {
        listOps__0002.push(listOpBytes);
      }
      if (i < 3) {
        listOps__0003.push(listOpBytes);
      }
      if (i < 4) {
        listOps__0004.push(listOpBytes);
      }
      if (i < 5) {
        listOps__0005.push(listOpBytes);
      }
      if (i < 10) {
        listOps__0010.push(listOpBytes);
      }
      if (i < 20) {
        listOps__0020.push(listOpBytes);
      }
      if (i < 30) {
        listOps__0030.push(listOpBytes);
      }
      if (i < 40) {
        listOps__0040.push(listOpBytes);
      }
      if (i < 50) {
        listOps__0050.push(listOpBytes);
      }
      if (i < 100) {
        listOps__0100.push(listOpBytes);
      }
      if (i < 200) {
        listOps__0200.push(listOpBytes);
      }
      if (i < 300) {
        listOps__0300.push(listOpBytes);
      }
      if (i < 400) {
        listOps__0400.push(listOpBytes);
      }
      if (i < 500) {
        listOps__0500.push(listOpBytes);
      }
      if (i < 1000) {
        listOps__1000.push(listOpBytes);
      }
    }
  }

  function encodeListOp(uint8 opType) internal view returns (bytes memory) {
    bytes memory result = abi.encodePacked(
      LIST_OP_VERSION, // Version for ListOp
      opType, // Operation type for ListOp (Add Record)
      LIST_RECORD_VERSION, // Version for ListRecord
      LIST_RECORD_TYPE_RAW_ADDRESS, // Record type for ListRecord (Raw Address)
      ADDRESS_1 // Raw address (20 bytes)
    );
    if (opType == LIST_OP_TYPE_ADD_TAG || opType == LIST_OP_TYPE_REMOVE_TAG) {
      result = abi.encodePacked(result, 'tag');
    }
    return result;
  }

  function test_applyListOp___0001() public {
    listRecords.applyListOp(NONCE, listOp);
  }

  function test_applyListOps__0001() public {
    listRecords.applyListOps(NONCE, listOps__0001);
  }

  function test_applyListOps__0002() public {
    listRecords.applyListOps(NONCE, listOps__0002);
  }

  function test_applyListOps__0003() public {
    listRecords.applyListOps(NONCE, listOps__0003);
  }

  function test_applyListOps__0004() public {
    listRecords.applyListOps(NONCE, listOps__0004);
  }

  function test_applyListOps__0005() public {
    listRecords.applyListOps(NONCE, listOps__0005);
  }

  function test_applyListOps__0010() public {
    listRecords.applyListOps(NONCE, listOps__0010);
  }

  function test_applyListOps__0020() public {
    listRecords.applyListOps(NONCE, listOps__0020);
  }

  function test_applyListOps__0030() public {
    listRecords.applyListOps(NONCE, listOps__0030);
  }

  function test_applyListOps__0040() public {
    listRecords.applyListOps(NONCE, listOps__0040);
  }

  function test_applyListOps__0050() public {
    listRecords.applyListOps(NONCE, listOps__0050);
  }

  function test_applyListOps__0100() public {
    listRecords.applyListOps(NONCE, listOps__0100);
  }

  function test_applyListOps__0200() public {
    listRecords.applyListOps(NONCE, listOps__0200);
  }

  function test_applyListOps__0300() public {
    listRecords.applyListOps(NONCE, listOps__0300);
  }

  function test_applyListOps__0400() public {
    listRecords.applyListOps(NONCE, listOps__0400);
  }

  function test_applyListOps__0500() public {
    listRecords.applyListOps(NONCE, listOps__0500);
  }

  function test_applyListOps__1000() public {
    listRecords.applyListOps(NONCE, listOps__1000);
  }
}
