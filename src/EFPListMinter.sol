// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import 'forge-std/console.sol';

import {Ownable} from 'lib/openzeppelin-contracts/contracts/access/Ownable.sol';
import {Pausable} from 'lib/openzeppelin-contracts/contracts/security/Pausable.sol';
import {IEFPAccountMetadata} from './interfaces/IEFPAccountMetadata.sol';
import {IEFPListRegistry} from './interfaces/IEFPListRegistry.sol';
import {IEFPListRecords} from './interfaces/IEFPListRecords.sol';
import {ENSReverseClaimer} from './lib/ENSReverseClaimer.sol';

interface IEFPListRegistry_ERC721 is IEFPListRegistry {
  function ownerOf(uint256 tokenId) external view returns (address);

  function totalSupply() external view returns (uint256);
}

contract EFPListMinter is ENSReverseClaimer, Pausable {
  IEFPListRegistry_ERC721 public registry;
  IEFPAccountMetadata public accountMetadata;
  IEFPListRecords public listRecordsL1;

  constructor(address _registryAddress, address _accountMetadataAddress, address _listRecordsL1) {
    registry = IEFPListRegistry_ERC721(_registryAddress);
    accountMetadata = IEFPAccountMetadata(_accountMetadataAddress);
    listRecordsL1 = IEFPListRecords(_listRecordsL1);
  }

  /////////////////////////////////////////////////////////////////////////////
  // Pausable
  /////////////////////////////////////////////////////////////////////////////

  /**
   * @dev Pauses the contract. Can only be called by the contract owner.
   */
  function pause() public onlyOwner {
    _pause();
  }

  /**
   * @dev Unpauses the contract. Can only be called by the contract owner.
   */
  function unpause() public onlyOwner {
    _unpause();
  }

  /////////////////////////////////////////////////////////////////////////////
  // minting
  /////////////////////////////////////////////////////////////////////////////

  function decodeL1ListStorageLocationNone(
    bytes calldata listStorageLocation
  ) internal pure returns (uint256, address) {
    // the list storage location is
    // - version (1 byte)
    // - list storate location type (1 byte)
    // - chain id (32 bytes)
    // - contract address (20 bytes)
    // - slot (32 bytes)
    require(listStorageLocation.length == 1 + 1 + 32 + 20 + 32, 'EFPListMinter: invalid list storage location');
    require(listStorageLocation[0] == 0x01, 'EFPListMinter: invalid list storage location version');
    require(listStorageLocation[1] == 0x01, 'EFPListMinter: invalid list storage location type');
    address contractAddress = _bytesToAddress(listStorageLocation, 34);

    uint256 slot = _bytesToUint(listStorageLocation, 54);
    return (slot, contractAddress);
  }

  function easyMint(bytes calldata listStorageLocation) public payable whenNotPaused {
    // validate the list storage location
    (uint256 slot, address recordsContract) = decodeL1ListStorageLocationNone(listStorageLocation);

    uint256 tokenId = registry.totalSupply();
    registry.mintTo{value: msg.value}(msg.sender, listStorageLocation);
    _setDefaultListForAccount(msg.sender, tokenId);
    if (recordsContract == address(listRecordsL1)) {
      listRecordsL1.setListUser(slot, msg.sender);
      listRecordsL1.setListManager(slot, msg.sender);
    }
  }

  function easyMintTo(address to, bytes calldata listStorageLocation) public payable whenNotPaused {
    // validate the list storage location
    (uint256 slot, address recordsContract) = decodeL1ListStorageLocationNone(listStorageLocation);

    uint256 tokenId = registry.totalSupply();
    registry.mintTo{value: msg.value}(to, listStorageLocation);
    _setDefaultListForAccount(msg.sender, tokenId);
    if (recordsContract == address(listRecordsL1)) {
      listRecordsL1.setListUser(slot, msg.sender);
      listRecordsL1.setListManager(slot, msg.sender);
    }
  }

  function mintNoMeta(bytes calldata listStorageLocation) public payable whenNotPaused {
    // validate the list storage location
    decodeL1ListStorageLocationNone(listStorageLocation);

    registry.mintTo{value: msg.value}(msg.sender, listStorageLocation);
  }

  function mintToNoMeta(address to, bytes calldata listStorageLocation) public payable whenNotPaused {
    // validate the list storage location
    decodeL1ListStorageLocationNone(listStorageLocation);

    registry.mintTo{value: msg.value}(to, listStorageLocation);
  }

  function _setDefaultListForAccount(address to, uint256 tokenId) internal {
    accountMetadata.setValueForAddress(to, 'primary-list', abi.encodePacked(tokenId));
  }

  function _getChainId() internal view returns (uint256) {
    uint256 id;
    assembly {
      id := chainid()
    }
    return id;
  }

  // Generalized function to convert bytes to uint256 with a given offset
  function _bytesToUint(bytes memory data, uint256 offset) internal pure returns (uint256) {
    require(data.length >= offset + 32, 'Data too short');
    uint256 value;
    assembly {
      value := mload(add(data, add(32, offset)))
    }
    return value;
  }

  // Helper function to convert bytes to address with a given offset
  function _bytesToAddress(bytes memory data, uint256 offset) internal pure returns (address addr) {
    require(data.length >= offset + 20, 'Data too short');
    assembly {
      // Extract 20 bytes from the specified offset
      addr := mload(add(add(data, 20), offset))
      // clear the 12 least significant bits of the address
      addr := and(addr, 0x000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
    }
    return addr;
  }
}
