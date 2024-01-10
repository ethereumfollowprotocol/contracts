// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import 'forge-std/Test.sol';
import {EFPListRegistry} from '../src/EFPListRegistry.sol';
import {IEFPListRegistry} from '../src/interfaces/IEFPListRegistry.sol';

contract EFPListRegistryTest is Test {
  uint8 constant VERSION = 1;
  uint8 constant LIST_LOCATION_TYPE = 1;
  address constant MOCK_LIST_ADDRESS = address(0x123);

  EFPListRegistry public registry;

  function setUp() public {
    registry = new EFPListRegistry();
  }

  function _bytesToAddress(bytes memory data) private pure returns (address addr) {
    assembly {
      addr := mload(add(data, 20))
    }
  }

  function _bytesToStructOfUintAddressUint(
    bytes memory data
  ) private pure returns (uint256 chainId, address contractAddress, uint256 nonce) {
    assembly {
      chainId := mload(add(data, 32))
      contractAddress := mload(add(data, 52))
      nonce := mload(add(data, 84))
    }
  }

  function getChainId() external view returns (uint256) {
    uint256 id;
    assembly {
      id := chainid()
    }
    return id;
  }

  function makeListStorageLocation(uint256 nonce) private view returns (bytes memory) {
    return abi.encodePacked(VERSION, LIST_LOCATION_TYPE, this.getChainId(), MOCK_LIST_ADDRESS, nonce);
  }

  function test_CanSetMintState() public {
    registry.setMintState(IEFPListRegistry.MintState.OwnerOnly);
    EFPListRegistry.MintState mintState = registry.getMintState();
    assertEq(uint256(mintState), uint256(IEFPListRegistry.MintState.OwnerOnly));
  }

  function test_CanMint() public {
    assertEq(registry.totalSupply(), 0);
    registry.setMintState(IEFPListRegistry.MintState.PublicMint);
    registry.mint(makeListStorageLocation(0));
    assertEq(registry.totalSupply(), 1);
    assertEq(registry.balanceOf(address(this)), 1);
    assertEq(registry.ownerOf(0), address(this));
    assertEq(registry.getListStorageLocation(0), makeListStorageLocation(0));
  }

  function test_CanMintTo() public {
    assertEq(registry.totalSupply(), 0);
    registry.setMintState(IEFPListRegistry.MintState.PublicMint);
    registry.mintTo(address(this), makeListStorageLocation(0));
    assertEq(registry.totalSupply(), 1);
    assertEq(registry.balanceOf(address(this)), 1);
    assertEq(registry.ownerOf(0), address(this));
    assertEq(registry.getListStorageLocation(0), makeListStorageLocation(0));
  }

  function test_CanMintBatch() public {
    assertEq(registry.totalSupply(), 0);
    registry.setMintState(IEFPListRegistry.MintState.PublicMint);
    registry.mintBatch(2);
    assertEq(registry.totalSupply(), 2);
    assertEq(registry.balanceOf(address(this)), 2);
    assertEq(registry.ownerOf(0), address(this));
    assertEq(registry.ownerOf(1), address(this));
    assertEq(registry.getListStorageLocation(0), new bytes(0));
    assertEq(registry.getListStorageLocation(1), new bytes(0));
  }

  function test_CanMintBatchTo() public {
    assertEq(registry.totalSupply(), 0);
    registry.setMintState(IEFPListRegistry.MintState.PublicMint);
    registry.mintBatchTo(address(this), 2);
    assertEq(registry.totalSupply(), 2);
    assertEq(registry.balanceOf(address(this)), 2);
    assertEq(registry.ownerOf(0), address(this));
    assertEq(registry.ownerOf(1), address(this));
    assertEq(registry.getListStorageLocation(0), new bytes(0));
    assertEq(registry.getListStorageLocation(1), new bytes(0));
  }

  function test_CanSetListStorageLocation() public {
    registry.setMintState(IEFPListRegistry.MintState.PublicMint);
    registry.mint(makeListStorageLocation(0));
    // now change storage location
    registry.setListStorageLocation(0, makeListStorageLocation(1));
    assertEq(registry.getListStorageLocation(0), makeListStorageLocation(1));
  }

  function test_RevertIf_SetListStorageLocationAsNonOwner() public {
    bytes memory listStorageLocation = makeListStorageLocation(0);
    registry.setMintState(IEFPListRegistry.MintState.PublicMint);
    registry.mint(listStorageLocation);
    assertEq(registry.getListStorageLocation(0), listStorageLocation);

    bytes memory newListStorageLocation = makeListStorageLocation(1);
    vm.prank(address(1));
    vm.expectRevert('EFP: caller is not the owner');
    registry.setListStorageLocation(0, newListStorageLocation);
    console.logBytes(registry.getListStorageLocation(0));
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external pure returns (bytes4) {
    return bytes4(keccak256('onERC721Received(address,address,uint256,bytes)'));
  }
}
