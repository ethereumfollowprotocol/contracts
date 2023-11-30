// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {EFPAccountMetadata} from "../../src/beta/EFPAccountMetadata.sol";
import {EFPListMetadata} from "../../src/beta/EFPListMetadata.sol";
import {EFPListRegistry} from "../../src/beta/EFPListRegistry.sol";
import {EFPLists} from "../../src/beta/EFPLists.sol";
import {EFPListMinter} from "../../src/beta/EFPListMinter.sol";

contract EFPListMinterTest is Test {
    EFPAccountMetadata public accountMetadata;
    EFPListMetadata public listMetadata;
    EFPListRegistry public registry;
    EFPLists public lists;
    EFPListMinter public minter;

    uint NONCE_L1 = 1234;
    bytes1 LIST_LOCATION_VERSION = bytes1(0x01);
    bytes1 LIST_LOCATION_TYPE_L1 = bytes1(0x01);
    bytes1 LIST_LOCATION_TYPE_L2 = bytes1(0x02);

    function setUp() public {
        accountMetadata = new EFPAccountMetadata();
        listMetadata = new EFPListMetadata();
        registry = new EFPListRegistry();
        lists = new EFPLists();
        listMetadata.setEFPListRegistry(address(registry));
        registry.setMintState(EFPListRegistry.MintState.PublicMint);
        registry.mint();

        minter = new EFPListMinter(address(registry), address(accountMetadata), address(listMetadata), address(lists));
        accountMetadata.addProxy(address(minter));
        listMetadata.addProxy(address(minter));
    }

    function test_CanMintWithListLocationOnL1AndSetAsDefaultList() public {
        uint tokenId = registry.totalSupply();
        minter.mintWithListLocationOnL1AndSetAsDefaultList(NONCE_L1);

        assertEq(registry.ownerOf(tokenId), address(this));
        assertEq(accountMetadata.getValue(address(this), "efp.list.primary"), abi.encodePacked(tokenId));
        assertEq(listMetadata.getValue(uint(tokenId), "efp.list.location"), abi.encodePacked(LIST_LOCATION_VERSION, LIST_LOCATION_TYPE_L1, address(lists), NONCE_L1));
    }

    function test_CanMintWithListLocationOnL2AndSetAsDefaultList() public {
        uint chainId = 2222;
        address addressL2 = address(0x4444444);
        uint nonceL2 = 3333;
        uint tokenId = registry.totalSupply();
        minter.mintWithListLocationOnL2AndSetAsDefaultList(chainId, addressL2, nonceL2);

        assertEq(registry.ownerOf(tokenId), address(this));
        assertEq(accountMetadata.getValue(address(this), "efp.list.primary"), abi.encodePacked(tokenId));
        assertEq(listMetadata.getValue(uint(tokenId), "efp.list.location"), abi.encodePacked(LIST_LOCATION_VERSION, LIST_LOCATION_TYPE_L2, chainId, addressL2, nonceL2));
    }
}
