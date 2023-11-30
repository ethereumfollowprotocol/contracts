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
 * @notice This script deploys the EFP contracts and initializes them.
 */
contract DeployScript is Script {
    using Strings for uint256;

    EFPAccountMetadata public accountMetadata;
    EFPListRegistry public registry;
    EFPListMetadata public listMetadata;
    EFPLists public lists;
    EFPListMinter public minter;

    // uint lastTokenId = 0;
    // uint totalRecords = 0;
    // mapping(uint => ListRecord[]) public recordsMapping;
    // mapping(uint => ListOp[]) public listOpsMapping;

    function setUp() public {
        // Any setup needed before deployment
    }

    // function parseListOps() internal {
    //     // ListOp[] memory listOps = new ListOp[](totalRecords);
    //     // fill in listOpsMapping
    //     for (uint tokenId = 0; tokenId <= lastTokenId; tokenId++) {
    //         ListRecord[] memory records = recordsMapping[tokenId];

    //         // convert each record to a list op (add record) and add to listOps
    //         for (uint i = 0; i < records.length; i++) {
    //             ListRecord memory record = records[i];
    //             ListOp memory op = ListOp({
    //                 version: 0x01,
    //                 code: 0x01,
    //                 data: abi.encodePacked(record.version, record.recordType, record.data)
    //             });
    //             listOpsMapping[tokenId].push(op);
    //         }
    //     }
    // }

    function deployContracts() public {
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

    function initContracts() public {
        // Additional setup for registry and listMetadata if needed
        listMetadata.setEFPListRegistry(address(registry));
        // Add the minter as a proxy for accountMetadata and listMetadata
        accountMetadata.addProxy(address(minter));
        listMetadata.addProxy(address(minter));

        registry.setMintState(EFPListRegistry.MintState.PublicMint);
        console.log('Mint state         : PublicMint');
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
        vm.startBroadcast(deployerPrivateKey);

        // msg.sender will be set to the address derived from the private key
        // you're using for the transaction, specified in the
        // vm.startBroadcast(deployerPrivateKey) call.
        console.log(
            StringUtils.GREEN,
            'Deployer           :',
            msg.sender,
            StringUtils.ENDC
        );
        // address(this) refers to the address of the currently executing
        // contract. In your deployment script, this refers to the instance
        // of the DeployScript contract.
        // console.log(GREEN, "address(this)      :", address(this), StringUtils.ENDC);
        console.log();

        // Deploy the contracts
        deployContracts();

        // initialize the contracts
        initContracts();

        // loadCsv(vm.readFile("scripts/lists.csv"));
        // console.log('lastTokenId    :', lastTokenId);
        // console.log('totalRecords   :', totalRecords);
        // parseListOps();
        // // add all list ops to Lists
        // for (uint tid = 0; tid <= lastTokenId; tid++) {
        //     minter.mintWithListLocationOnL1AndSetAsDefaultList(tid);
        //     lists.claimListManager(tid);
        //     ListOp[] memory listOps = listOpsMapping[tid];
        //     bytes[] memory asBytes = new bytes[](listOps.length);
        //     for (uint i = 0; i < listOps.length; i++) {
        //         asBytes[i] = abi.encodePacked(listOps[i].version, listOps[i].code, listOps[i].data);
        //     }
        //     lists.applyListOps(tid, asBytes);
        // }

        // // print all token ids and owners
        // console.log();
        // Logger.logNFTs(address(registry));
        // console.log();
        // Logger.logListOps(0, lastTokenId, listOpsMapping);

        vm.stopBroadcast();
    }
}
