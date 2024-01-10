// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import 'forge-std/console.sol';

import {Colors} from './Colors.sol';
import {ContractConfigs} from './ContractConfigs.sol';
import {Contracts} from './Contracts.sol';
import {StringUtils} from './StringUtils.sol';

import {EFPAccountMetadata} from '../../src/EFPAccountMetadata.sol';
import {EFPListMinter} from '../../src/EFPListMinter.sol';
import {EFPListRegistry} from '../../src/EFPListRegistry.sol';
import {EFPListRecords} from '../../src/EFPListRecords.sol';
import {IEFPAccountMetadata} from '../../src/interfaces/IEFPAccountMetadata.sol';
import {IEFPListRegistry} from '../../src/interfaces/IEFPListRegistry.sol';
import {IEFPListRecords} from '../../src/interfaces/IEFPListRecords.sol';

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
    console.log(Colors.BLUE, 'Deployer           :', msg.sender, Colors.ENDC);
    console.log();

    // EFPAccountMetadata
    IEFPAccountMetadata accountMetadata;
    if (isContract(ContractConfigs.EFP_ACCOUNT_METADATA)) {
      accountMetadata = EFPAccountMetadata(ContractConfigs.EFP_ACCOUNT_METADATA);
      console.log(' EFPAccountMetadata :', address(accountMetadata));
    } else {
      accountMetadata = new EFPAccountMetadata();
      console.log(Colors.GREEN, 'EFPAccountMetadata :', address(accountMetadata), Colors.ENDC);
    }

    // EFPListRegistry
    IEFPListRegistry listRegistry;
    if (isContract(ContractConfigs.EFP_LIST_REGISTRY)) {
      listRegistry = EFPListRegistry(ContractConfigs.EFP_LIST_REGISTRY);
      console.log(' EFPListRegistry    :', address(listRegistry));
    } else {
      listRegistry = new EFPListRegistry();
      console.log(Colors.GREEN, 'EFPListRegistry    :', address(listRegistry), Colors.ENDC);
    }

    // EFPListRecords
    IEFPListRecords listRecords;
    if (isContract(ContractConfigs.EFP_LIST_RECORDS)) {
      listRecords = EFPListRecords(ContractConfigs.EFP_LIST_RECORDS);
      console.log(' EFPListRecords     :', address(listRecords));
    } else {
      listRecords = new EFPListRecords();
      console.log(Colors.GREEN, 'EFPListRecords     :', address(listRecords), Colors.ENDC);
    }

    // EFPListMinter
    EFPListMinter listMinter;
    if (isContract(ContractConfigs.EFP_LIST_MINTER)) {
      listMinter = EFPListMinter(ContractConfigs.EFP_LIST_MINTER);
      console.log(' EFPListMinter      :', address(listMinter));
    } else {
      listMinter = new EFPListMinter(
        address(listRegistry),
        address(accountMetadata),
        // address(listMetadata),
        address(listRecords)
      );
      console.log(Colors.GREEN, 'EFPListMinter      :', address(listMinter), Colors.ENDC);
    }

    console.log();
    return
      Contracts({
        accountMetadata: address(accountMetadata),
        listRegistry: address(listRegistry),
        // listMetadata: address(listMetadata),
        listRecords: address(listRecords),
        listMinter: address(listMinter)
      });
  }

  /**
   * @notice Performs initial configuration for the deployed EFP contracts.
   */
  function initContracts(Contracts memory contracts) public {
    // Add the minter as a proxy for accountMetadata and listMetadata
    if (!IEFPAccountMetadata(contracts.accountMetadata).isProxy(contracts.listMinter)) {
      console.log(Colors.GREEN, 'Adding EFPListMinter as proxy for EFPAccountMetadata', Colors.ENDC);
      IEFPAccountMetadata(contracts.accountMetadata).addProxy(contracts.listMinter);
    } else {
      console.log(' EFPListMinter address already a proxy for EFPAccountMetadata');
    }
  }

  /**
   * @notice Loads all EFP smart contracts, reverts if any are not deployed.
   * @return A Contracts struct containing all loaded contract addresses.
   */
  function loadAll() public view returns (Contracts memory) {
    Contracts memory contracts;

    // Load EFPAccountMetadata
    if (isContract(ContractConfigs.EFP_ACCOUNT_METADATA)) {
      contracts.accountMetadata = ContractConfigs.EFP_ACCOUNT_METADATA;
      console.log(Colors.BLUE, 'EFPAccountMetadata :', contracts.accountMetadata, Colors.ENDC);
    } else {
      revert('EFPAccountMetadata not deployed');
    }

    // Load EFPListRegistry
    if (isContract(ContractConfigs.EFP_LIST_REGISTRY)) {
      contracts.listRegistry = ContractConfigs.EFP_LIST_REGISTRY;
      console.log(Colors.BLUE, 'EFPListRegistry    :', contracts.listRegistry, Colors.ENDC);
    } else {
      revert('EFPListRegistry not deployed');
    }

    // Load EFPListRecords
    if (isContract(ContractConfigs.EFP_LIST_RECORDS)) {
      contracts.listRecords = ContractConfigs.EFP_LIST_RECORDS;
      console.log(Colors.BLUE, 'EFPListRecords     :', contracts.listRecords, Colors.ENDC);
    } else {
      revert('EFPListRecords not deployed');
    }

    // Load EFPListMinter
    if (isContract(ContractConfigs.EFP_LIST_MINTER)) {
      contracts.listMinter = ContractConfigs.EFP_LIST_MINTER;
      console.log(Colors.BLUE, 'EFPListMinter      :', contracts.listMinter, Colors.ENDC);
    } else {
      revert('EFPListMinter not deployed');
    }

    console.log();
    return contracts;
  }
}
