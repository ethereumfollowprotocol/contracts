// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {EFPAccountMetadata} from "../src/EFPAccountMetadata.sol";
import {EFPListRegistry} from "../src/EFPListRegistry.sol";
import {IEFPAccountMetadata} from "../src/interfaces/IEFPAccountMetadata.sol";
import {ListStorageLocation} from "../src/types/ListStorageLocation.sol";

contract EFPAccountMetadataTest is Test {
    EFPAccountMetadata public metadata;

    function setUp() public {
        metadata = new EFPAccountMetadata();
    }

    function test_CanSetValue() public {
        metadata.setValue("key", "value");
        assertEq(metadata.getValue(address(this), "key"), "value");
    }

    function test_CanSetValueForAddress() public {
        metadata.setValueForAddress(address(this), "key", "value");
        assertEq(metadata.getValue(address(this), "key"), "value");
    }

    function test_CanSetValues() public {
        // array of key-values to pass in
        IEFPAccountMetadata.KeyValue[] memory records = new IEFPAccountMetadata.KeyValue[](2);
        records[0] = IEFPAccountMetadata.KeyValue("key1", "value1");
        records[1] = IEFPAccountMetadata.KeyValue("key2", "value2");
        metadata.setValues(records);
        assertEq(metadata.getValue(address(this), "key1"), "value1");
        assertEq(metadata.getValue(address(this), "key2"), "value2");
        string[] memory keys = new string[](2);
        keys[0] = "key1";
        keys[1] = "key2";
        bytes[] memory values = metadata.getValues(address(this), keys);
        assertEq(values[0], "value1");
        assertEq(values[1], "value2");
    }

    function test_CanSetValuesForAddress() public {
        // array of key-values to pass in
        IEFPAccountMetadata.KeyValue[] memory records = new IEFPAccountMetadata.KeyValue[](2);
        records[0] = IEFPAccountMetadata.KeyValue("key1", "value1");
        records[1] = IEFPAccountMetadata.KeyValue("key2", "value2");
        metadata.setValuesForAddress(address(this), records);
        assertEq(metadata.getValue(address(this), "key1"), "value1");
        assertEq(metadata.getValue(address(this), "key2"), "value2");
        string[] memory keys = new string[](2);
        keys[0] = "key1";
        keys[1] = "key2";
        bytes[] memory values = metadata.getValues(address(this), keys);
        assertEq(values[0], "value1");
        assertEq(values[1], "value2");
    }

    function test_RevertIf_SetValueFromDifferentAddress() public {
        // cannot set value if don't own token
        // try calling from another address
        vm.prank(address(1));
        vm.expectRevert("not allowed");
        metadata.setValueForAddress(address(this), "key", "value");
    }

    function test_RevertIf_SetValuesForAddressFromDifferentAddress() public {
        IEFPAccountMetadata.KeyValue[] memory records = new IEFPAccountMetadata.KeyValue[](2);
        records[0] = IEFPAccountMetadata.KeyValue("key1", "value1");
        records[1] = IEFPAccountMetadata.KeyValue("key2", "value2");

        vm.prank(address(1));
        vm.expectRevert("not allowed");
        metadata.setValuesForAddress(address(this), records);
    }
}
