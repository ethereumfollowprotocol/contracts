// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import 'forge-std/Test.sol';
import {EFPListRecords} from '../src/EFPListRecords.sol';
import {IEFPListMetadata, IEFPListRecords} from '../src/interfaces/IEFPListRecords.sol';

contract EFPListMetadataTest is Test {
  uint256 constant NONCE = 0;
  EFPListRecords public listRecords;

  function setUp() public {
    listRecords = new EFPListRecords();
  }

  /////////////////////////////////////////////////////////////////////////////
  // constructor
  /////////////////////////////////////////////////////////////////////////////

  function test_ListManagerInitializesToZeroAddress() public {
    assertEq(listRecords.getListManager(NONCE), address(0));
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
  // setListUser
  /////////////////////////////////////////////////////////////////////////////

  function test_CanSetListUser() public {
    listRecords.claimListManager(NONCE);
    listRecords.setListUser(NONCE, address(1));
    assertEq(listRecords.getListUser(NONCE), address(1));
  }

  function test_RevertIf_SetListUserWhenPaused() public {
    listRecords.claimListManager(NONCE);
    listRecords.pause();
    vm.expectRevert('Pausable: paused');
    listRecords.setListUser(NONCE, address(1));
  }

  function test_RevertIf_SetListUserFromNonManager() public {
    listRecords.claimListManager(NONCE);
    vm.prank(address(1));
    vm.expectRevert('Not list manager');
    listRecords.setListUser(NONCE, address(1));
  }

  /////////////////////////////////////////////////////////////////////////////
  // setMetadataValue
  /////////////////////////////////////////////////////////////////////////////

  function test_CanSetMetadataValue() public {
    listRecords.claimListManager(NONCE);
    listRecords.setMetadataValue(NONCE, 'key', 'value');
    assertEq(listRecords.getMetadataValue(NONCE, 'key'), 'value');
  }

  function test_CanSetMetadataValueAfterChangeListManager() public {
    listRecords.claimListManager(NONCE);
    listRecords.setListManager(NONCE, address(1));
    vm.prank(address(1));
    listRecords.setMetadataValue(NONCE, 'key', 'value');
    assertEq(listRecords.getMetadataValue(NONCE, 'key'), 'value');
  }

  function test_RevertIf_SetMetadataValueWhenPaused() public {
    listRecords.claimListManager(NONCE);
    listRecords.pause();
    vm.expectRevert('Pausable: paused');
    listRecords.setMetadataValue(NONCE, 'key', 'value');
  }

  function test_RevertIf_SetMetadataValueFromNonManager() public {
    listRecords.claimListManager(NONCE);
    // cannot set value if don't own token
    // try calling from another address
    vm.prank(address(1));
    vm.expectRevert('Not list manager');
    listRecords.setMetadataValue(NONCE, 'key', 'value');
  }

  /////////////////////////////////////////////////////////////////////////////
  // setMetadataValues
  /////////////////////////////////////////////////////////////////////////////

  function test_CanSetMetadataValues() public {
    listRecords.claimListManager(NONCE);
    // array of key-values to pass in
    IEFPListMetadata.KeyValue[] memory records = new IEFPListMetadata.KeyValue[](2);
    records[0] = IEFPListMetadata.KeyValue('key1', 'value1');
    records[1] = IEFPListMetadata.KeyValue('key2', 'value2');
    listRecords.setMetadataValues(NONCE, records);
    assertEq(listRecords.getMetadataValue(NONCE, 'key1'), 'value1');
    assertEq(listRecords.getMetadataValue(NONCE, 'key2'), 'value2');
    string[] memory keys = new string[](2);
    keys[0] = 'key1';
    keys[1] = 'key2';
    bytes[] memory values = listRecords.getMetadataValues(NONCE, keys);
    assertEq(values[0], 'value1');
    assertEq(values[1], 'value2');
  }

  function test_RevertIf_SetMetadataValuesWhenPaused() public {
    listRecords.claimListManager(NONCE);
    listRecords.pause();
    vm.expectRevert('Pausable: paused');
    // array of key-values to pass in
    IEFPListMetadata.KeyValue[] memory records = new IEFPListMetadata.KeyValue[](2);
    records[0] = IEFPListMetadata.KeyValue('key1', 'value1');
    records[1] = IEFPListMetadata.KeyValue('key2', 'value2');
    listRecords.setMetadataValues(NONCE, records);
  }

  function test_RevertIf_SetMetadataValuesFromNonManager() public {
    IEFPListMetadata.KeyValue[] memory records = new IEFPListMetadata.KeyValue[](2);
    records[0] = IEFPListMetadata.KeyValue('key1', 'value1');
    records[1] = IEFPListMetadata.KeyValue('key2', 'value2');

    listRecords.claimListManager(NONCE);

    vm.prank(address(1));
    vm.expectRevert('Not list manager');
    listRecords.setMetadataValues(NONCE, records);
  }
}
