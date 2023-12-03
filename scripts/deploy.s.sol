// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {console} from "lib/forge-std/src/console.sol";
import {Script} from "lib/forge-std/src/Script.sol";

import {Contracts} from "./util/Contracts.sol";
import {Deployer} from "./util/Deployer.sol";

/**
 * @title A Foundry script to deploy and initialize EFP contracts
 * @dev Inherits from the Script class provided by Forge standard library
 */
contract DeployScript is Script, Deployer {
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
     * @notice Executes the script to deploy and initialize the EFP contracts.
     */
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        console.log(vm.envUint("PRIVATE_KEY"));

        // Deploy the contracts
        Contracts memory contracts = deployAll();

        // initialize the contracts
        initContracts(contracts);

        vm.stopBroadcast();
    }
}
