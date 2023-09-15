// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ListRegistry.sol";


contract ListRegistryTest is Test {
    ListRegistry public registry;

    function setUp() public {
        registry = new ListRegistry();
    }

    function _bytesToAddress(bytes memory data) private pure returns (address addr) {
        assembly {
            addr := mload(add(data, 20))
        }
    }

    function testMint() public {
        assertEq(registry.totalSupply(), 0);
        registry.mint();
        assertEq(registry.totalSupply(), 1);
        assertEq(registry.balanceOf(address(this)), 1);
        assertEq(registry.ownerOf(0), address(this));
    }

    function testMintTo() public {
        assertEq(registry.totalSupply(), 0);
        registry.mintTo(address(this));
        assertEq(registry.totalSupply(), 1);
        assertEq(registry.balanceOf(address(this)), 1);
        assertEq(registry.ownerOf(0), address(this));
    }

    function testSetListStorageLocation() public {
        registry.mint();
        registry.setListStorageLocationL1(0, address(this));
        // Assuming a way to get the list location in ListRegistry
        ListStorageLocation memory listStorageLocation = registry.getListStorageLocation(0);
        assertEq(listStorageLocation.version, 1);
        assertEq(listStorageLocation.locationType, 1);
        address decodedAddress = _bytesToAddress(listStorageLocation.data);
        assertEq(decodedAddress, address(this));

    }

    function testSetManager() public {
        registry.mint();
        registry.setManager(0, address(0xAbc));
        assertEq(registry.getManager(0), address(0xAbc));
    }

    function testGetManager() public {
        registry.mint();
        assertEq(registry.getManager(0), address(this));
    }

    function testManagerFallbackToOwner() public {
        registry.mint();
        assertEq(registry.getManager(0), address(this));
    }

    function testSetUser() public {
        registry.mint();
        registry.setManager(0, address(this));
        registry.setUser(0, address(0xDef));
        assertEq(registry.getUser(0), address(0xDef));
    }

    function testGetUser() public {
        registry.mint();
        assertEq(registry.getUser(0), address(this));
    }

    function testUserFallbackToOwner() public {
        registry.mint();
        assertEq(registry.getUser(0), address(this));
    }
}
