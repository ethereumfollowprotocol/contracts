// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IEFPAccountMetadata} from "./interfaces/IEFPAccountMetadata.sol";
import {IEFPListRegistry} from "./interfaces/IEFPListRegistry.sol";
import {IEFPListRecords} from "./interfaces/IEFPListRecords.sol";

interface IEFPListRegistry_ERC721 is IEFPListRegistry {
    function ownerOf(uint256 tokenId) external view returns (address);
    function totalSupply() external view returns (uint256);
}

contract EFPListMinter is Ownable {
    IEFPListRegistry_ERC721 public registry;
    IEFPAccountMetadata public accountMetadata;
    IEFPListRecords public listRecordsL1;

    constructor(address _registryAddress, address _accountMetadataAddress, address _listRecordsL1) {
        registry = IEFPListRegistry_ERC721(_registryAddress);
        accountMetadata = IEFPAccountMetadata(_accountMetadataAddress);
        listRecordsL1 = IEFPListRecords(_listRecordsL1);
    }

    function mintAndSetAsDefaultList(bytes calldata listStorageLocation) public payable {
        // the list storage location is
        // - version (1 byte)
        // - list storate location type (1 byte)
        // - chain id (32 bytes)
        // - contract address (20 bytes)
        // - nonce (32 bytes)
        require(listStorageLocation.length == 1 + 1 + 32 + 20 + 32, "EFPListMinter: invalid list storage location");
        require(listStorageLocation[0] == 0x01, "EFPListMinter: invalid list storage location version");
        require(listStorageLocation[1] == 0x01, "EFPListMinter: invalid list storage location type");
        uint256 listLocationChainId = _bytesToUint(listStorageLocation, 2);
        require(listLocationChainId == _getChainId(), "EFPListMinter: invalid list storage location chain id");
        address listLocationContractAddress = _bytesToAddress(listStorageLocation, 34);
        require(listLocationContractAddress == address(listRecordsL1), "EFPListMinter: invalid list storage location contract address");

        uint256 tokenId = registry.totalSupply();
        registry.mintTo{value: msg.value}(msg.sender, listStorageLocation);
        _setDefaultListForAccount(msg.sender, tokenId);

        uint256 listLocationNonce = _bytesToUint(listStorageLocation, 54);
        listRecordsL1.claimListManagerForAddress(listLocationNonce, msg.sender);
    }

    function mintToAndSetAsDefaultList(address to, bytes calldata listStorageLocation) public payable {
        require(listStorageLocation.length == 1 + 1 + 32 + 20 + 32, "EFPListMinter: invalid list storage location");
        require(listStorageLocation[0] == 0x01, "EFPListMinter: invalid list storage location version");
        require(listStorageLocation[1] == 0x01, "EFPListMinter: invalid list storage location type");

        uint256 tokenId = registry.totalSupply();
        registry.mintTo{value: msg.value}(to, listStorageLocation);
        _setDefaultListForAccount(to, tokenId);
        // _setListLocationL1(tokenId, address(listRecordsL1), nonceL1);
        // listRecordsL1.claimListManagerForAddress(nonceL1, to);
    }

    function _setDefaultListForAccount(address to, uint256 tokenId) internal {
        accountMetadata.setValueForAddress(to, "primary-list", abi.encodePacked(tokenId));
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
        require(data.length >= offset + 32, "Data too short");
        uint value;
        assembly {
            value := mload(add(data, add(32, offset)))
        }
        return value;
    }

    // Helper function to convert bytes to address with a given offset
    function _bytesToAddress(bytes memory data, uint256 offset) internal pure returns (address addr) {
        require(data.length >= offset + 20, "Data too short");
        assembly {
            // Extract 20 bytes from the specified offset
            addr := mload(add(add(data, 20), offset))
            // clear the 12 least significant bits of the address
            addr := and(addr, 0x000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        }
        return addr;
    }
}
