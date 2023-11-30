// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {console} from "lib/forge-std/src/console.sol";

import {Colors} from "./Colors.sol";
import {ContractConfigs} from "./ContractConfigs.sol";
import {Contracts} from "./Contracts.sol";
import {StringUtils} from "./StringUtils.sol";

import {EFPAccountMetadata} from "../../src/beta/EFPAccountMetadata.sol";
import {EFPListMetadata} from "../../src/beta/EFPListMetadata.sol";
import {EFPListMinter} from "../../src/beta/EFPListMinter.sol";
import {EFPListRegistry} from "../../src/beta/EFPListRegistry.sol";
import {EFPLists} from "../../src/beta/EFPLists.sol";
import {IEFPAccountMetadata} from "../../src/beta/IEFPAccountMetadata.sol";
import {IEFPListMetadata} from "../../src/beta/IEFPListMetadata.sol";
import {IEFPListRegistry} from "../../src/beta/IEFPListRegistry.sol";
import {IEFPLists} from "../../src/beta/IEFPLists.sol";

contract Deployer {
    /*
     * @notice Checks if the given address is a contract by checking the code size.
     * @param addr The address to check.
     * @return True if the address is a contract, false otherwise.
     */
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /**
     * @notice Deploys the EFP smart contracts.
     */
    function deployAll() public returns (Contracts memory) {
        console.log(Colors.BLUE, "Deployer           :", msg.sender, Colors.ENDC);
        console.log();

        // EFPAccountMetadata
        IEFPAccountMetadata accountMetadata;
        if (isContract(ContractConfigs.EFP_ACCOUNT_METADATA)) {
            accountMetadata = EFPAccountMetadata(ContractConfigs.EFP_ACCOUNT_METADATA);
            console.log(" EFPAccountMetadata :", address(accountMetadata));
        } else {
            accountMetadata = new EFPAccountMetadata();
            console.log(Colors.GREEN, "EFPAccountMetadata :", address(accountMetadata), Colors.ENDC);
        }

        // EFPListRegistry
        IEFPListRegistry listRegistry;
        if (isContract(ContractConfigs.EFP_LIST_REGISTRY)) {
            listRegistry = EFPListRegistry(ContractConfigs.EFP_LIST_REGISTRY);
            console.log(" EFPListRegistry    :", address(listRegistry));
        } else {
            listRegistry = new EFPListRegistry();
            console.log(Colors.GREEN, "EFPListRegistry    :", address(listRegistry), Colors.ENDC);
        }

        // EFPListMetadata
        IEFPListMetadata listMetadata;
        if (isContract(ContractConfigs.EFP_LIST_METADATA)) {
            listMetadata = EFPListMetadata(ContractConfigs.EFP_LIST_METADATA);
            console.log(" EFPListMetadata    :", address(listMetadata));
        } else {
            listMetadata = new EFPListMetadata();
            console.log(Colors.GREEN, "EFPListMetadata    :", address(listMetadata), Colors.ENDC);
        }

        // EFPLists
        IEFPLists lists;
        if (isContract(ContractConfigs.EFP_LISTS)) {
            lists = EFPLists(ContractConfigs.EFP_LISTS);
            console.log(" EFPLists           :", address(lists));
        } else {
            lists = new EFPLists();
            console.log(Colors.GREEN, "EFPLists           :", address(lists), Colors.ENDC);
        }

        // EFPListMinter
        EFPListMinter listMinter;
        if (isContract(ContractConfigs.EFP_LIST_MINTER)) {
            listMinter = EFPListMinter(ContractConfigs.EFP_LIST_MINTER);
            console.log(" EFPListMinter      :", address(listMinter));
        } else {
            listMinter =
            new EFPListMinter(address(listRegistry), address(accountMetadata), address(listMetadata), address(lists));
            console.log(Colors.GREEN, "EFPListMinter      :", address(listMinter), Colors.ENDC);
        }

        console.log();
        return Contracts({
            accountMetadata: address(accountMetadata),
            listRegistry: address(listRegistry),
            listMetadata: address(listMetadata),
            lists: address(lists),
            listMinter: address(listMinter)
        });
    }

    /**
     * @notice Performs initial configuration for the deployed EFP contracts.
     */
    function initContracts(Contracts memory contracts) public {
        // Set the list registry address in the account metadata contract
        address listRegistryAddress = IEFPListMetadata(contracts.listMetadata).getEFPListRegistry();
        if (listRegistryAddress != contracts.listRegistry) {
            console.log(Colors.GREEN, "Setting EFPListRegistry address in EFPListMetadata", Colors.ENDC);
            require(listRegistryAddress == address(0), "List registry already set incorrectly");
            IEFPListMetadata(contracts.listMetadata).setEFPListRegistry(contracts.listRegistry);
        } else {
            console.log(" EFPListRegistry address already set in EFPListMetadata");
        }

        // Add the minter as a proxy for accountMetadata and listMetadata
        if (!IEFPAccountMetadata(contracts.accountMetadata).isProxy(contracts.listMinter)) {
            console.log(Colors.GREEN, "Adding EFPListMinter as proxy for EFPAccountMetadata", Colors.ENDC);
            IEFPAccountMetadata(contracts.accountMetadata).addProxy(contracts.listMinter);
        } else {
            console.log(" EFPListMinter address already a proxy for EFPAccountMetadata");
        }

        if (!IEFPListMetadata(contracts.listMetadata).isProxy(contracts.listMinter)) {
            console.log(Colors.GREEN, "Adding EFPListMinter as proxy for EFPListMetadata", Colors.ENDC);
            IEFPListMetadata(contracts.listMetadata).addProxy(contracts.listMinter);
        } else {
            console.log(" EFPListMinter address already a proxy for EFPListMetadata");
        }
    }
}
