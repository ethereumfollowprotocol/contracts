// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {ListRegistry} from "../../src/alpha/ListRegistry.sol";
import {ListStorageLocation} from "../../src/alpha/ListStorageLocation.sol";


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

    function _bytesToStructOfUintAddressUint(bytes memory data) private pure returns (uint chainId, address contractAddress, uint nonce) {
        assembly {
            chainId := mload(add(data, 32))
            contractAddress := mload(add(data, 52))
            nonce := mload(add(data, 84))
        }
    }

    function test_CanMint() public {
        assertEq(registry.totalSupply(), 0);
        registry.mint();
        assertEq(registry.totalSupply(), 1);
        assertEq(registry.balanceOf(address(this)), 1);
        assertEq(registry.ownerOf(0), address(this));
    }

    function test_CanMintTo() public {
        assertEq(registry.totalSupply(), 0);
        registry.mintTo(address(this));
        assertEq(registry.totalSupply(), 1);
        assertEq(registry.balanceOf(address(this)), 1);
        assertEq(registry.ownerOf(0), address(this));
    }

    function test_CanSetListStorageLocationL1() public {
        registry.mint();
        registry.setListStorageLocationL1(0, address(this));
        // Assuming a way to get the list location in ListRegistry
        ListStorageLocation memory listStorageLocation = registry.getListStorageLocation(0);
        assertEq(listStorageLocation.version, 1);
        assertEq(listStorageLocation.locationType, 1);
        address decodedAddress = _bytesToAddress(listStorageLocation.data);
        assertEq(decodedAddress, address(this));
    }

    function test_CanSetListStorageLocationL2WithNonce() public {
        registry.mint();

        uint chainId = 1234;
        address contractAddress = address(123);
        uint nonce = 123456789;
        registry.setListStorageLocationL2WithNonce(0, chainId, contractAddress, nonce);
        // Assuming a way to get the list location in ListRegistry
        ListStorageLocation memory listStorageLocation = registry.getListStorageLocation(0);
        assertEq(listStorageLocation.version, 1);
        assertEq(listStorageLocation.locationType, 2);
        (uint decodedChainId, address decodedContractAddress, uint decodedNonce) = _bytesToStructOfUintAddressUint(listStorageLocation.data);
        assertEq(decodedChainId, chainId);
        assertEq(decodedContractAddress, contractAddress);
        assertEq(decodedNonce, nonce);
    }

    function test_CanSetManager() public {
        registry.mint();
        registry.setManager(0, address(0xAbc));
        assertEq(registry.getManager(0), address(0xAbc));
    }

    function test_CanGetManager() public {
        registry.mint();
        assertEq(registry.getManager(0), address(this));
    }

    function test_CanManagerFallbackToOwner() public {
        registry.mint();
        assertEq(registry.getManager(0), address(this));
    }

    function test_CanSetUser() public {
        registry.mint();
        registry.setManager(0, address(this));
        registry.setUser(0, address(0xDef));
        assertEq(registry.getUser(0), address(0xDef));
    }

    function test_CanGetUser() public {
        registry.mint();
        assertEq(registry.getUser(0), address(this));
    }

    function test_CanUserFallbackToOwner() public {
        registry.mint();
        assertEq(registry.getUser(0), address(this));
    }
}
