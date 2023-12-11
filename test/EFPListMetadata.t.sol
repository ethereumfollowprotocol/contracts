// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {EFPListMetadata} from "../src/EFPListMetadata.sol";
import {EFPListRegistry} from "../src/EFPListRegistry.sol";
import {IEFPListMetadata} from "../src/IEFPListMetadata.sol";
import {IEFPListRegistry} from "../src/IEFPListRegistry.sol";
import {ListStorageLocation} from "../src/ListStorageLocation.sol";

contract EFPListMetadataTest is Test {
    EFPListRegistry public registry;
    EFPListMetadata public metadata;

    function setUp() public {
        registry = new EFPListRegistry();
        metadata = new EFPListMetadata();
        metadata.setEFPListRegistry(address(registry));
        registry.setMintState(IEFPListRegistry.MintState.OwnerOnly);
        registry.mint(new bytes(0));
    }

    function test_CanSetValue() public {
        metadata.setValue(0, "key", "value");
        assertEq(metadata.getValue(0, "key"), "value");
    }

    function test_CanSetValues() public {
        // array of key-values to pass in
        IEFPListMetadata.KeyValue[] memory records = new IEFPListMetadata.KeyValue[](2);
        records[0] = IEFPListMetadata.KeyValue("key1", "value1");
        records[1] = IEFPListMetadata.KeyValue("key2", "value2");
        metadata.setValues(0, records);
        assertEq(metadata.getValue(0, "key1"), "value1");
        assertEq(metadata.getValue(0, "key2"), "value2");
        string[] memory keys = new string[](2);
        keys[0] = "key1";
        keys[1] = "key2";
        bytes[] memory values = metadata.getValues(0, keys);
        assertEq(values[0], "value1");
        assertEq(values[1], "value2");
    }

    function test_RevertIf_SetValueFromNonTokenOwner() public {
        // cannot set value if don't own token
        // try calling from another address
        vm.prank(address(1));
        vm.expectRevert("not token owner");
        metadata.setValue(0, "key", "value");
    }

    function test_RevertIf_SetValuesFromNonTokenOwner() public {
        IEFPListMetadata.KeyValue[] memory records = new IEFPListMetadata.KeyValue[](2);
        records[0] = IEFPListMetadata.KeyValue("key1", "value1");
        records[1] = IEFPListMetadata.KeyValue("key2", "value2");

        vm.prank(address(1));
        vm.expectRevert("not token owner");
        metadata.setValues(0, records);
    }
}
