// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {console} from "lib/forge-std/src/console.sol";
import {Script} from "lib/forge-std/src/Script.sol";
import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {IERC721Enumerable} from "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import {BytesUtils} from "./util/BytesUtils.sol";
import {Colors} from "./util/Colors.sol";
import {ContractConfigs} from "./util/ContractConfigs.sol";
import {Contracts} from "./util/Contracts.sol";
import {CSVUtils} from "./util/CSVUtils.sol";
import {Deployer} from "./util/Deployer.sol";
import {Logger} from "./util/Logger.sol";
import {StringUtils} from "./util/StringUtils.sol";

import {EFPAccountMetadata} from "../src/EFPAccountMetadata.sol";
import {EFPListMinter} from "../src/EFPListMinter.sol";
import {EFPListRegistry} from "../src/EFPListRegistry.sol";
import {EFPListRecords} from "../src/EFPListRecords.sol";
import {IEFPListRegistry} from "../src/IEFPListRegistry.sol";
import {IEFPListRecords} from "../src/IEFPListRecords.sol";
import {ListOp} from "../src/ListOp.sol";
import {ListRecord} from "../src/ListRecord.sol";

/**
 * @notice This script deploys the EFP contracts and initializes them.
 */
contract MintScript is Script, Deployer {
    using Strings for uint256;

    uint256 lastTokenId = 0;
    uint256 totalRecords = 0;
    // mapping(uint256 => ListRecord[]) public recordsMapping;
    mapping(uint256 => ListOp[]) public listOpsMapping;

    function setUp() public {
        // Any setup needed before deployment
    }

    function ensurePublicMint(Contracts memory contracts) public {
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

            // uint256 efp_nft_token_id = StringUtils.stringToUint(values[0]);
            uint256 nonce = StringUtils.stringToUint(values[0]);
            // require(efp_nft_token_id == nonce, "efp_nft_token_id does not match nonce");

            // console.log(
            //     'i=%d, require(efp_nft_token_id=%d >= %d=lastTokenId, "tokenIds are not monotonically increasing");',
            //     i,
            //     efp_nft_token_id,
            //     lastTokenId
            // );
            require(nonce >= lastTokenId, "tokenIds are not monotonically increasing");


            string memory listOpHex = values[1];

            bytes memory listOpBytes = StringUtils.hexStringToBytes(listOpHex);
            uint8 listOpVersion = uint8(listOpBytes[0]);
            uint8 listOpCode = uint8(listOpBytes[1]);
            bytes memory listOpData = BytesUtils.slice(listOpBytes, 2, listOpBytes.length - 2);
            ListOp memory listOp = ListOp({
                version: listOpVersion,
                code: listOpCode,
                data: listOpData
            });

            listOpsMapping[nonce].push(listOp);
            // console.log(
            //     "LOADED EFP NFT #%d record #%d as %s", efp_nft_token_id, record_num, StringUtils.bytesToHexString(data)
            // );

            lastTokenId = nonce; // Update lastTokenId after processing the line
        }
    }

    function listOpsToBytes(ListOp[] memory listOps) public pure returns (bytes[] memory) {
        bytes[] memory asBytes = new bytes[](listOps.length);
        for (uint256 i = 0; i < listOps.length; i++) {
            asBytes[i] = abi.encodePacked(listOps[i].version, listOps[i].code, listOps[i].data);
        }
        return asBytes;
    }

    function getChainId() external view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function makeListStorageLocation(address listRecordsAddress, uint nonce) private view returns (bytes memory) {
        uint8 VERSION = 1;
        uint8 LIST_LOCATION_TYPE = 1;
        return abi.encodePacked(VERSION, LIST_LOCATION_TYPE, this.getChainId(), listRecordsAddress, nonce);
    }

    function mints(Contracts memory contracts) public {
        uint256 totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
        for (uint256 tid = totalSupply; tid <= lastTokenId; tid++) {
            console.log("minting token id %d with nonce %d", tid, tid);
            bytes memory listStorageLocation = makeListStorageLocation(contracts.listRecords, tid);
            EFPListMinter(contracts.listMinter).mintAndSetAsDefaultList(listStorageLocation);
            // claim list manager
            EFPListRecords(contracts.listRecords).claimListManager(tid);
            // IEFPListRecords(contracts.listRecords).claimListManager(tid);
            ListOp[] memory listOps = listOpsMapping[tid];
            uint256 currentListOpCount = IEFPListRecords(contracts.listRecords).getListOpCount(tid);
            if (currentListOpCount == 0) {
                IEFPListRecords(contracts.listRecords).applyListOps(tid, listOpsToBytes(listOps));
            }
        }
    }

    function mintOne(Contracts memory contracts) public {
        uint256 totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
        uint tokenId = totalSupply;
        console.log("minting token id %d with nonce %d", totalSupply, totalSupply);
        bytes memory listStorageLocation = makeListStorageLocation(contracts.listRecords, totalSupply);
        EFPListMinter(contracts.listMinter).mintAndSetAsDefaultList(listStorageLocation);
        EFPListRecords(contracts.listRecords).claimListManager(totalSupply);
        totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
        lastTokenId = totalSupply;
        // IEFPListRecords(contracts.listRecords).claimListManager(totalSupply);
        // create a single list op to follow the zero address
        ListRecord memory listRecordToFollow = ListRecord({
            version: 0x01,
            recordType: 0x01,
            data: abi.encodePacked(address(0x0))
        });
        ListOp[] memory listOps = new ListOp[](1);
        listOps[0] = ListOp({
            version: 0x01,
            code: 0x01,
            data: abi.encodePacked(listRecordToFollow.version, listRecordToFollow.recordType, listRecordToFollow.data)
        });
        console.log("applying %d list op%s to token id %d", listOps.length, listOps.length == 1 ? "" : "s", tokenId);
        IEFPListRecords(contracts.listRecords).applyListOps(tokenId, listOpsToBytes(listOps));
        totalRecords++;
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        console.log(deployerPrivateKey);
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
        ensurePublicMint(contracts);
        console.log();

        // determine the total number of records
        loadCsv(vm.readFile("scripts/data/fizzbuzz.csv"));
        // parseListOps();

        // add all list ops to ListRecords
        uint256 initialTotalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
        if (initialTotalSupply <= lastTokenId) {
            mints(contracts);
        } else {
            // mint one more
            mintOne(contracts);
        }
        uint totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();

        // // print all token ids and owners
        Logger.logNFTs(contracts.listRegistry, initialTotalSupply);
        console.log();
        Logger.logListOps(contracts, initialTotalSupply, totalSupply - 1);

        vm.stopBroadcast();
    }
}
