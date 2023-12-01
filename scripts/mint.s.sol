// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {console} from "lib/forge-std/src/console.sol";
import {Script} from "lib/forge-std/src/Script.sol";
import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {IERC721Enumerable} from "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import {Colors} from "./util/Colors.sol";
import {ContractConfigs} from "./util/ContractConfigs.sol";
import {Contracts} from "./util/Contracts.sol";
import {CSVUtils} from "./util/CSVUtils.sol";
import {Deployer} from "./util/Deployer.sol";
import {Logger} from "./util/Logger.sol";
import {StringUtils} from "./util/StringUtils.sol";

import {EFPAccountMetadata} from "../src/beta/EFPAccountMetadata.sol";
import {EFPListMetadata} from "../src/beta/EFPListMetadata.sol";
import {EFPListMinter} from "../src/beta/EFPListMinter.sol";
import {EFPListRegistry} from "../src/beta/EFPListRegistry.sol";
import {EFPLists} from "../src/beta/EFPLists.sol";
import {IEFPListRegistry} from "../src/beta/IEFPListRegistry.sol";
import {IEFPLists} from "../src/beta/IEFPLists.sol";
import {ListOp} from "../src/beta/ListOp.sol";
import {ListRecord} from "../src/beta/ListRecord.sol";

/**
 * @notice This script deploys the EFP contracts and initializes them.
 */
contract DeployScript is Script, Deployer {
    using Strings for uint256;

    uint256 lastTokenId = 0;
    uint256 totalRecords = 0;
    mapping(uint256 => ListRecord[]) public recordsMapping;
    mapping(uint256 => ListOp[]) public listOpsMapping;

    function setUp() public {
        // Any setup needed before deployment
    }

    function initMint(Contracts memory contracts) public {
        console.log(" totalSupply        :", IERC721Enumerable(contracts.listRegistry).totalSupply());

        IEFPListRegistry.MintState mintState = IEFPListRegistry(contracts.listRegistry).getMintState();
        string memory s = " Mint state         : ";
        if (mintState == IEFPListRegistry.MintState.Disabled) {
            s = string.concat(s, "Disabled");
        } else if (mintState == IEFPListRegistry.MintState.OwnerOnly) {
            s = string.concat(s, "OwnerOnly");
        } else if (mintState == IEFPListRegistry.MintState.PublicMint) {
            s = string.concat(s, "PublicMint");
        } else if (mintState == IEFPListRegistry.MintState.PublicBatch) {
            s = string.concat(s, "PublicBatch");
        } else {
            revert("Unknown mint state");
        }

        IEFPListRegistry.MintState desired = IEFPListRegistry.MintState.PublicMint;
        if (mintState != desired) {
            IEFPListRegistry(contracts.listRegistry).setMintState(desired);
            s = string.concat(s, " -> ", Colors.GREEN, "PublicMint", Colors.ENDC);
        }
        console.log(s);
    }

    // Helper function to parse the CSV and populate the recordsMapping
    function loadCsv(string memory csv) internal {
        string[] memory lines = CSVUtils.split(csv, "\n");
        lastTokenId = 0; // Initialize lastTokenId to 0

        for (uint256 i = 1; i < lines.length; i++) {
            // Start from 1 to skip the header
            string memory line = lines[i];
            // Skip empty lines
            if (bytes(line).length == 0) {
                continue;
            }
            string[] memory values = CSVUtils.split(lines[i], ",");

            uint256 efp_nft_token_id = StringUtils.stringToUint(values[0]);

            // console.log(
            //     'i=%d, require(efp_nft_token_id=%d >= %d=lastTokenId, "tokenIds are not monotonically increasing");',
            //     i,
            //     efp_nft_token_id,
            //     lastTokenId
            // );
            require(efp_nft_token_id >= lastTokenId, "tokenIds are not monotonically increasing");

            uint256 nonce = StringUtils.stringToUint(values[1]);
            uint256 record_num = StringUtils.stringToUint(values[2]);

            require(efp_nft_token_id == nonce, "efp_nft_token_id does not match nonce");
            require(record_num == recordsMapping[efp_nft_token_id].length, "record_num is not sequential");

            uint8 version = uint8(StringUtils.stringToUint(values[3]));
            uint8 list_record_type = uint8(StringUtils.stringToUint(values[4]));
            bytes memory data = abi.encodePacked(StringUtils.stringToAddress(values[5]));

            ListRecord memory record = ListRecord({version: version, recordType: list_record_type, data: data});

            recordsMapping[efp_nft_token_id].push(record);
            // console.log(
            //     "LOADED EFP NFT #%d record #%d as %s", efp_nft_token_id, record_num, StringUtils.bytesToHexString(data)
            // );

            lastTokenId = efp_nft_token_id; // Update lastTokenId after processing the line
        }
    }

    function parseListOps() public {
        // ListOp[] memory listOps = new ListOp[](totalRecords);
        // fill in listOpsMapping
        for (uint256 tokenId = 0; tokenId <= lastTokenId; tokenId++) {
            ListRecord[] memory records = recordsMapping[tokenId];

            // convert each record to a list op (add record) and add to listOps
            for (uint256 i = 0; i < records.length; i++) {
                ListRecord memory record = records[i];
                ListOp memory op = ListOp({
                    version: 0x01,
                    code: 0x01,
                    data: abi.encodePacked(record.version, record.recordType, record.data)
                });
                listOpsMapping[tokenId].push(op);
            }
        }
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // msg.sender will be set to the address derived from the private key
        // you're using for the transaction, specified in the
        // vm.startBroadcast(deployerPrivateKey) call.
        console.log(Colors.GREEN, "Deployer           :", msg.sender, Colors.ENDC);
        // address(this) refers to the address of the currently executing
        // contract. In your deployment script, this refers to the instance
        // of the DeployScript contract.
        // console.log(GREEN, "address(this)      :", address(this), Colors.ENDC);
        console.log();

        // initialize the contracts
        Contracts memory contracts = loadAll();
        initMint(contracts);
        console.log();

        loadCsv(vm.readFile("scripts/lists.csv"));
        // console.log("lastTokenId    :", lastTokenId);
        // console.log("totalRecords   :", totalRecords);

        parseListOps();
        // add all list ops to Lists
        uint256 totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
        for (uint256 tid = totalSupply; tid <= lastTokenId; tid++) {
            EFPListMinter(contracts.listMinter).mintWithListLocationOnL1AndSetAsDefaultList(tid);
            IEFPLists(contracts.lists).claimListManager(tid);
            ListOp[] memory listOps = listOpsMapping[tid];
            uint256 currentListOpCount = IEFPLists(contracts.lists).getListOpCount(tid);
            if (currentListOpCount == 0) {
                bytes[] memory asBytes = new bytes[](listOps.length);
                for (uint256 i = 0; i < listOps.length; i++) {
                    asBytes[i] = abi.encodePacked(listOps[i].version, listOps[i].code, listOps[i].data);
                }
                IEFPLists(contracts.lists).applyListOps(tid, asBytes);
            }
        }

        // // print all token ids and owners
        Logger.logNFTs(contracts.listRegistry);
        console.log();
        Logger.logListOps(0, lastTokenId, listOpsMapping);

        vm.stopBroadcast();
    }
}
