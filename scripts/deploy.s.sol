// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import "forge-std/Script.sol";

import { EFPAccountMetadata } from "../src/beta/EFPAccountMetadata.sol";
import { EFPListMetadata } from "../src/beta/EFPListMetadata.sol";
import { EFPListRegistry } from "../src/beta/EFPListRegistry.sol";
import { EFPLists } from "../src/beta/EFPLists.sol";
import { EFPListMinter } from "../src/beta/EFPListMinter.sol";

contract DeployScript is Script {
    function setUp() public {
        // Any setup needed before deployment
    }

    function run() public {
        vm.startBroadcast();

        // Deploy the contracts
        EFPAccountMetadata accountMetadata = new EFPAccountMetadata();
        console.log("EFPAccountMetadata :", address(accountMetadata));
        EFPListRegistry registry = new EFPListRegistry();
        console.log("EFPListRegistry    :", address(registry));
        EFPListMetadata listMetadata = new EFPListMetadata();
        console.log("EFPListMetadata    :", address(listMetadata));
        EFPLists lists = new EFPLists();
        console.log("EFPLists           :", address(lists));

        // Additional setup for registry and listMetadata if needed
        listMetadata.setEFPListRegistry(address(registry));

        EFPListMinter minter = new EFPListMinter(
            address(registry),
            address(accountMetadata),
            address(listMetadata),
            address(lists)
        );
        console.log("EFPListMinter      :", address(minter));
        console.log();

        // Add the minter as a proxy for accountMetadata and listMetadata
        accountMetadata.addProxy(address(minter));
        listMetadata.addProxy(address(minter));

        registry.setMintState(EFPListRegistry.MintState.PublicMint);
        console.log("Mint state         : PublicMint");
        registry.mint();
        uint tokenId = registry.totalSupply() - 1;
        address owner = registry.ownerOf(tokenId);

        // Formatting the output as a row in the table
        console.log();
        console.log("---------------------------------------------------------");
        console.log("| Token ID |                    Owner                   |");
        console.log("---------------------------------------------------------");
        console.log("|    #%d    | %s |", tokenId, owner);
        console.log("---------------------------------------------------------");

        vm.stopBroadcast();
    }
}
