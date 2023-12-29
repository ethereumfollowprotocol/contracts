// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

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
        uint256 tokenId = registry.totalSupply();
        registry.mintTo{value: msg.value}(msg.sender, listStorageLocation);
        _setDefaultListForAccount(msg.sender, tokenId);
        // _setListLocationL1(tokenId, address(listRecordsL1), nonceL1);
        // listRecordsL1.claimListManagerForAddress(nonceL1, msg.sender);
    }

    function mintToAndSetAsDefaultList(address to, bytes calldata listStorageLocation) public payable {
        uint256 tokenId = registry.totalSupply();
        registry.mintTo{value: msg.value}(to, listStorageLocation);
        _setDefaultListForAccount(to, tokenId);
        // _setListLocationL1(tokenId, address(listRecordsL1), nonceL1);
        // listRecordsL1.claimListManagerForAddress(nonceL1, to);
    }

    function _setDefaultListForAccount(address to, uint256 tokenId) internal {
        accountMetadata.setValueForAddress(to, "primary-list", abi.encodePacked(tokenId));
    }
}
