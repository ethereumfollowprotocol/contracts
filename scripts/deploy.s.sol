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
    string RED = "\x1b[31m";
    string GREEN = "\x1b[32m";
    string BLUE = "\x1b[34m";
    string ENDC = "\x1b[0m";

    function setUp() public {
        // Any setup needed before deployment
    }

    function run() public {
        vm.startBroadcast();

        console.log(GREEN, "Deployer           :", msg.sender, ENDC);
        console.log();

        // Deploy the contracts
        EFPAccountMetadata accountMetadata = new EFPAccountMetadata();
        console.log(BLUE, "EFPAccountMetadata :", address(accountMetadata), ENDC);
        EFPListRegistry registry = new EFPListRegistry();
        console.log(BLUE, "EFPListRegistry    :", address(registry), ENDC);
        EFPListMetadata listMetadata = new EFPListMetadata();
        console.log(BLUE, "EFPListMetadata    :", address(listMetadata), ENDC);
        EFPLists lists = new EFPLists();
        console.log(BLUE, "EFPLists           :", address(lists), ENDC);

        // Additional setup for registry and listMetadata if needed
        listMetadata.setEFPListRegistry(address(registry));

        EFPListMinter minter = new EFPListMinter(
            address(registry),
            address(accountMetadata),
            address(listMetadata),
            address(lists)
        );
        console.log(BLUE, "EFPListMinter      :", address(minter), ENDC);
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
