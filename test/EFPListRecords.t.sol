// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import 'forge-std/Test.sol';
import {EFPListRecords} from '../src/EFPListRecords.sol';

contract EFPListRecordsTest is Test {
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
  uint256 constant NONCE = 0;

  function setUp() public {
    listRecords = new EFPListRecords();
  }

  // Helper function to compare bytes
  function _assertBytesEqual(bytes memory a, bytes memory b) internal pure {
    assert(a.length == b.length);
    for (uint256 i = 0; i < a.length; i++) {
      assert(a[i] == b[i]);
    }
  }

  function _encodeListOp(uint8 opType) internal view returns (bytes memory) {
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

  /////////////////////////////////////////////////////////////////////////////
  // pause
  /////////////////////////////////////////////////////////////////////////////

  function test_CanPause() public {
    assertEq(listRecords.paused(), false);
    listRecords.pause();
    assertEq(listRecords.paused(), true);
  }

  /////////////////////////////////////////////////////////////////////////////
  // unpause
  /////////////////////////////////////////////////////////////////////////////

  function test_CanUnpause() public {
    listRecords.pause();
    listRecords.unpause();
    assertEq(listRecords.paused(), false);
  }

  /////////////////////////////////////////////////////////////////////////////
  // claimListManager
  /////////////////////////////////////////////////////////////////////////////

  function test_CanClaimListManager() public {
    listRecords.claimListManager(NONCE);
    assertEq(listRecords.getListManager(NONCE), address(this));
  }

  function test_RevertIf_ClaimListManagerWhenPaused() public {
    listRecords.pause();
    vm.expectRevert('Pausable: paused');
    listRecords.claimListManager(NONCE);
  }

  /////////////////////////////////////////////////////////////////////////////
  // setListManager
  /////////////////////////////////////////////////////////////////////////////

  function test_CanSetListManager() public {
    listRecords.claimListManager(NONCE);
    listRecords.setListManager(NONCE, address(1));
    assertEq(listRecords.getListManager(NONCE), address(1));
  }

  function test_RevertIf_SetListManagerWhenPaused() public {
    listRecords.claimListManager(NONCE);
    listRecords.pause();
    vm.expectRevert('Pausable: paused');
    listRecords.setListManager(NONCE, address(1));
  }

  function test_RevertIf_SetListManagerFromNonManager() public {
    listRecords.claimListManager(NONCE);
    vm.prank(address(1));
    vm.expectRevert('Not list manager');
    listRecords.setListManager(NONCE, address(1));
  }

  /////////////////////////////////////////////////////////////////////////////
  // applyListOp
  /////////////////////////////////////////////////////////////////////////////

  function _CanApplyListOp(uint8 opType) internal {
    assertEq(listRecords.getListOpCount(NONCE), 0);

    // listRecords.claimListManager(NONCE);

    bytes memory listOp = _encodeListOp(opType);
    listRecords.applyListOp(NONCE, listOp);

    assertEq(listRecords.getListOpCount(NONCE), 1);
    _assertBytesEqual(listRecords.getListOp(NONCE, 0), listOp);
  }

  function test_CanApplyListOpToAddRecord() public {
    _CanApplyListOp(LIST_OP_TYPE_ADD_RECORD);
  }

  function test_CanApplyListOpToRemoveRecord() public {
    _CanApplyListOp(LIST_OP_TYPE_REMOVE_RECORD);
  }

  function test_CanApplyListOpToAddTag() public {
    _CanApplyListOp(LIST_OP_TYPE_ADD_TAG);
  }

  function test_CanApplyListOpToRemoveTag() public {
    _CanApplyListOp(LIST_OP_TYPE_REMOVE_TAG);
  }

  function test_RevertIf_ApplyListOpWhenPaused() public {
    listRecords.pause();
    vm.expectRevert('Pausable: paused');
    listRecords.applyListOp(NONCE, _encodeListOp(LIST_OP_TYPE_ADD_RECORD));
  }

  /////////////////////////////////////////////////////////////////////////////
  // applyListOps
  /////////////////////////////////////////////////////////////////////////////

  function test_CanApplyListOpsSingular() public {
    assertEq(listRecords.getListOpCount(NONCE), 0);

    bytes[] memory listOps = new bytes[](1);
    listOps[0] = _encodeListOp(LIST_OP_TYPE_ADD_RECORD);
    listRecords.applyListOps(NONCE, listOps);

    assertEq(listRecords.getListOpCount(NONCE), 1);
    _assertBytesEqual(listRecords.getListOp(NONCE, 0), listOps[0]);
  }

  function test_CanApplyListOpsMultiple() public {
    assertEq(listRecords.getListOpCount(NONCE), 0);

    bytes[] memory listOps = new bytes[](2);
    listOps[0] = _encodeListOp(LIST_OP_TYPE_ADD_RECORD);
    listOps[1] = _encodeListOp(LIST_OP_TYPE_REMOVE_RECORD);
    listRecords.applyListOps(NONCE, listOps);

    assertEq(listRecords.getListOpCount(NONCE), 2);
    _assertBytesEqual(listRecords.getListOp(NONCE, 0), listOps[0]);
    _assertBytesEqual(listRecords.getListOp(NONCE, 1), listOps[1]);
  }

  function test_RevertIf_applyListOpsWhenPaused() public {
    listRecords.pause();
    vm.expectRevert('Pausable: paused');
    bytes[] memory listOps = new bytes[](2);
    listOps[0] = _encodeListOp(LIST_OP_TYPE_ADD_RECORD);
    listOps[1] = _encodeListOp(LIST_OP_TYPE_REMOVE_RECORD);
    listRecords.applyListOps(NONCE, listOps);
  }
}
