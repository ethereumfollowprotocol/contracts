// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { console } from 'lib/forge-std/src/console.sol';
import { Script } from 'lib/forge-std/src/Script.sol';
import { Strings } from 'lib/openzeppelin-contracts/contracts/utils/Strings.sol';

import { CSVUtils } from './util/CSVUtils.sol';
import { Logger } from './util/Logger.sol';
import { StringUtils } from './util/StringUtils.sol';

import { EFPAccountMetadata } from '../src/beta/EFPAccountMetadata.sol';
import { EFPListMetadata } from '../src/beta/EFPListMetadata.sol';
import { EFPListMinter } from '../src/beta/EFPListMinter.sol';
import { EFPListRegistry } from '../src/beta/EFPListRegistry.sol';
import { EFPLists } from '../src/beta/EFPLists.sol';
import { ListOp } from '../src/beta/ListOp.sol';
import { ListRecord } from '../src/beta/ListRecord.sol';

/**
 * @title A Foundry script to deploy and initialize EFP contracts
 * @dev Inherits from the Script class provided by Forge standard library
 */
contract DeployScript is Script {
    using Strings for uint256;

    EFPAccountMetadata public accountMetadata;
    EFPListRegistry public registry;
    EFPListMetadata public listMetadata;
    EFPLists public lists;
    EFPListMinter public minter;

    /**
     * @notice Performs any necessary setup before the deployment of contracts.
     * @dev This function can be used to set initial states or variables, or to perform checks.
     * It's an optional preparatory step before the main deployment actions.
     */
    function setUp() public {
        // This function is for any setup required before deploying the contracts.
        // It is an optional function and can be used to set initial states or variables.
    }

    /**
     * @notice Deploys the EFP smart contracts.
     */
    function deployContracts() public {
        console.log(
            StringUtils.GREEN,
            'Deployer           :',
            msg.sender,
            StringUtils.ENDC
        );
        console.log();

        accountMetadata = new EFPAccountMetadata();
        console.log(
            StringUtils.BLUE,
            'EFPAccountMetadata :',
            address(accountMetadata),
            StringUtils.ENDC
        );
        registry = new EFPListRegistry();
        console.log(
            StringUtils.BLUE,
            'EFPListRegistry    :',
            address(registry),
            StringUtils.ENDC
        );
        listMetadata = new EFPListMetadata();
        console.log(
            StringUtils.BLUE,
            'EFPListMetadata    :',
            address(listMetadata),
            StringUtils.ENDC
        );
        lists = new EFPLists();
        console.log(
            StringUtils.BLUE,
            'EFPLists           :',
            address(lists),
            StringUtils.ENDC
        );

        minter = new EFPListMinter(
            address(registry),
            address(accountMetadata),
            address(listMetadata),
            address(lists)
        );
        console.log(
            StringUtils.BLUE,
            'EFPListMinter      :',
            address(minter),
            StringUtils.ENDC
        );
        console.log();
    }

    /**
     * @notice Performs initial configuration for the deployed EFP contracts.
     */
    function initContracts() public {
        // Additional setup for registry and listMetadata if needed
        listMetadata.setEFPListRegistry(address(registry));
        // Add the minter as a proxy for accountMetadata and listMetadata
        accountMetadata.addProxy(address(minter));
        listMetadata.addProxy(address(minter));
    }

    /**
     * @notice Executes the script to deploy and initialize the EFP contracts.
     */
    function run() public {
        vm.startBroadcast(vm.envUint('PRIVATE_KEY'));

        // Deploy the contracts
        deployContracts();

        // initialize the contracts
        initContracts();

        vm.stopBroadcast();
    }
}
