// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IEFPAccountMetadata} from "./IEFPAccountMetadata.sol";
import {IEFPListMetadata} from "./IEFPListMetadata.sol";
import {IEFPListRegistry} from "./IEFPListRegistry.sol";

interface IEFPListRegistry_ is IEFPListRegistry {
    function ownerOf(uint256 tokenId) external view returns (address);
    function totalSupply() external view returns (uint);
}

contract EFPListMinter {
    IEFPListRegistry_ public registry;
    IEFPAccountMetadata public accountMetadata;
    IEFPListMetadata public listMetadata;
    address public listsAddressL1;

    constructor(
        address _registryAddress,
        address _accountMetadataAddress,
        address _listMetadataAddress,
        address _listsAddressL1
    ) {
        registry = IEFPListRegistry_(_registryAddress);
        accountMetadata = IEFPAccountMetadata(_accountMetadataAddress);
        listMetadata = IEFPListMetadata(_listMetadataAddress);
        listsAddressL1 = _listsAddressL1;
    }

    function mintWithListLocationOnL1AndSetAsDefaultList(uint nonceL1) public payable {
        uint tokenId = registry.totalSupply();
        registry.mintTo{value: msg.value}(msg.sender);
        _setDefaultListForAccount(msg.sender, tokenId);
        _setListLocationL1(tokenId, listsAddressL1, nonceL1);
    }

    function mintToWithListLocationOnL1AndSetAsDefaultList(address to, uint nonceL1) public payable {
        uint tokenId = registry.totalSupply();
        registry.mintTo{value: msg.value}(to);
        _setDefaultListForAccount(to, tokenId);
        _setListLocationL1(tokenId, listsAddressL1, nonceL1);
    }

    function mintWithListLocationOnL2AndSetAsDefaultList(uint chainId, address addressL2, uint nonceL2) public payable {
        uint tokenId = registry.totalSupply();
        registry.mintTo{value: msg.value}(msg.sender);
        _setDefaultListForAccount(msg.sender, tokenId);
        _setListLocationL2(tokenId, chainId, addressL2, nonceL2);
    }

    function mintToWithListLocationOnL2AndSetAsDefaultList(
        address to,
        uint chainId,
        address addressL2,
        uint nonceL2
    ) public payable {
        uint tokenId = registry.totalSupply();
        registry.mintTo{value: msg.value}(to);
        _setDefaultListForAccount(to, tokenId);
        _setListLocationL2(tokenId, chainId, addressL2, nonceL2);
    }

    function _setDefaultListForAccount(address to, uint tokenId) internal {
        accountMetadata.setValueForAddress(to, "efp.list.primary", abi.encodePacked(tokenId));
    }

    function _setListLocationL1(uint tokenId, address addr, uint nonce) internal {
        bytes1 version = 0x01;
        bytes1 listLocationType = 0x01;
        listMetadata.setValue(tokenId, "efp.list.location", abi.encodePacked(version, listLocationType, addr, nonce));
    }

    function _setListLocationL2(uint tokenId, uint chainId, address addr, uint nonce) internal {
        bytes1 version = 0x01;
        bytes1 listLocationType = 0x02;
        listMetadata.setValue(
            tokenId,
            "efp.list.location",
            abi.encodePacked(version, listLocationType, chainId, addr, nonce)
        );
    }
}
