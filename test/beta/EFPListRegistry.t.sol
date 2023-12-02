// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {EFPListRegistry} from "../../src/beta/EFPListRegistry.sol";
import {IEFPListRegistry} from "../../src/beta/IEFPListRegistry.sol";
// import {ListStorageLocation} from "../../src/beta/ListStorageLocation.sol";

contract EFPListRegistryTest is Test {
    uint8 constant VERSION = 1;
    uint8 constant LIST_LOCATION_L1 = 1;
    uint8 constant LIST_LOCATION_L2_WITH_NONCE = 2;
    EFPListRegistry public registry;

    function setUp() public {
        registry = new EFPListRegistry();
    }

    function _bytesToAddress(bytes memory data) private pure returns (address addr) {
        assembly {
            addr := mload(add(data, 20))
        }
    }

    function _bytesToStructOfUintAddressUint(bytes memory data)
        private
        pure
        returns (uint256 chainId, address contractAddress, uint256 nonce)
    {
        assembly {
            chainId := mload(add(data, 32))
            contractAddress := mload(add(data, 52))
            nonce := mload(add(data, 84))
        }
    }

    function test_CanSetMintState() public {
        registry.setMintState(IEFPListRegistry.MintState.OwnerOnly);
        EFPListRegistry.MintState mintState = registry.getMintState();
        assertEq(uint256(mintState), uint256(IEFPListRegistry.MintState.OwnerOnly));
    }

    function test_CanMint() public {
        assertEq(registry.totalSupply(), 0);
        registry.setMintState(IEFPListRegistry.MintState.OwnerOnly);
        registry.mint();
        assertEq(registry.totalSupply(), 1);
        assertEq(registry.balanceOf(address(this)), 1);
        assertEq(registry.ownerOf(0), address(this));
    }

    function test_CanMintTo() public {
        assertEq(registry.totalSupply(), 0);
        registry.setMintState(IEFPListRegistry.MintState.OwnerOnly);
        registry.mintTo(address(this));
        assertEq(registry.totalSupply(), 1);
        assertEq(registry.balanceOf(address(this)), 1);
        assertEq(registry.ownerOf(0), address(this));
    }

    // function test_CanSetListStorageLocationL1() public {
    //     registry.setMintState(EFPListRegistry.MintState.OwnerOnly);
    //     registry.mint();
    //     ListStorageLocation memory listStorageLocationToSet = ListStorageLocation(VERSION, LIST_LOCATION_L1, abi.encodePacked(this));
    //     registry.setListStorageLocation(0, listStorageLocationToSet);
    //     // Assuming a way to get the list location in ListRegistry
    //     ListStorageLocation memory listStorageLocation = registry.getListStorageLocation(0);
    //     assertEq(listStorageLocation.version, 1);
    //     assertEq(listStorageLocation.locationType, 1);
    //     address decodedAddress = _bytesToAddress(listStorageLocation.data);
    //     assertEq(decodedAddress, address(this));
    // }

    // function test_CanSetListStorageLocationL2WithNonce() public {
    //     registry.setMintState(EFPListRegistry.MintState.OwnerOnly);
    //     registry.mint();

    //     uint chainId = 1234;
    //     address contractAddress = address(123);
    //     uint nonce = 123456789;
    //     ListStorageLocation memory listStorageLocationToSet = ListStorageLocation(VERSION, LIST_LOCATION_L2_WITH_NONCE, abi.encodePacked(chainId, contractAddress, nonce));
    //     registry.setListStorageLocation(0, listStorageLocationToSet);
    //     // Assuming a way to get the list location in ListRegistry
    //     ListStorageLocation memory listStorageLocation = registry.getListStorageLocation(0);
    //     assertEq(listStorageLocation.version, 1);
    //     assertEq(listStorageLocation.locationType, 2);
    //     (uint decodedChainId, address decodedContractAddress, uint decodedNonce) = _bytesToStructOfUintAddressUint(listStorageLocation.data);
    //     assertEq(decodedChainId, chainId);
    //     assertEq(decodedContractAddress, contractAddress);
    //     assertEq(decodedNonce, nonce);
    // }

    // function test_CanSetUser() public {
    //     registry.setMintState(EFPListRegistry.MintState.OwnerOnly);
    //     registry.mint();
    //     registry.setUser(0, address(0xDef));
    //     assertEq(registry.getUser(0), address(0xDef));
    // }

    // function test_CanGetUser() public {
    //     registry.setMintState(EFPListRegistry.MintState.OwnerOnly);
    //     registry.mint();
    //     assertEq(registry.getUser(0), address(this));
    // }

    // function test_CanUserFallbackToOwner() public {
    //     registry.setMintState(EFPListRegistry.MintState.OwnerOnly);
    //     registry.mint();
    //     assertEq(registry.getUser(0), address(this));
    // }
}
