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
import {ListOpUtils} from "./util/ListOpUtils.sol";
import {Logger} from "./util/Logger.sol";
import {StringUtils} from "./util/StringUtils.sol";

import {EFPAccountMetadata} from "../src/EFPAccountMetadata.sol";
import {EFPListMinter} from "../src/EFPListMinter.sol";
import {EFPListRegistry} from "../src/EFPListRegistry.sol";
import {EFPListRecords} from "../src/EFPListRecords.sol";
import {IEFPListRegistry} from "../src/interfaces/IEFPListRegistry.sol";
import {IEFPListRecords} from "../src/interfaces/IEFPListRecords.sol";
import {ListOp} from "../src/types/ListOp.sol";
import {ListRecord} from "../src/types/ListRecord.sol";

import {ListNFTsCsvLoader} from "./util/ListNFTsCsvLoader.sol";
import {ListOpsCsvLoader} from "./util/ListOpsCsvLoader.sol";

/**
 * @notice This script deploys the EFP contracts and initializes them.
 */
contract MintScript is Script, ListNFTsCsvLoader, ListOpsCsvLoader, Deployer {
    using Strings for uint256;
    using ListOpUtils for ListOp;

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

    function listOpsToBytes(ListOp[] memory listOps) public pure returns (bytes[] memory) {
        bytes[] memory asBytes = new bytes[](listOps.length);
        for (uint256 i = 0; i < listOps.length; i++) {
            asBytes[i] = listOps[i].encode();
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
        for (uint256 tokenId = totalSupply; tokenId <= lastTokenId; tokenId++) {
            console.log("minting token id %d with nonce %d", tokenId, tokenId);
            bytes memory listStorageLocation = makeListStorageLocation(contracts.listRecords, tokenId);
            EFPListMinter(contracts.listMinter).mintAndSetAsDefaultList(listStorageLocation);
            // claim list manager
            EFPListRecords(contracts.listRecords).claimListManager(tokenId);
            EFPListRecords(contracts.listRecords).setMetadataValue(
                tokenId,
                "user",
                abi.encodePacked(loadedListNfts[tokenId].listUser)
            );
            // IEFPListRecords(contracts.listRecords).claimListManager(tid);
            ListOp[] memory listOps = loadedListOpsMapping[tokenId];
            uint256 currentListOpCount = IEFPListRecords(contracts.listRecords).getListOpCount(tokenId);
            if (currentListOpCount == 0) {
                IEFPListRecords(contracts.listRecords).applyListOps(tokenId, listOpsToBytes(listOps));
            }
        }
    }

    function mintOne(Contracts memory contracts) public {
        uint256 totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
        uint tokenId = totalSupply;
        console.log("minting token id %d with nonce %d", totalSupply, totalSupply);
        bytes memory listStorageLocation = makeListStorageLocation(contracts.listRecords, totalSupply);
        EFPListMinter(contracts.listMinter).mintAndSetAsDefaultList(listStorageLocation);
        EFPListRecords(contracts.listRecords).claimListManager(tokenId);
        EFPListRecords(contracts.listRecords).setMetadataValue(
            tokenId,
            "user",
            abi.encodePacked(loadedListNfts[tokenId].listUser)
        );
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
            opcode: 0x01,
            data: abi.encodePacked(listRecordToFollow.version, listRecordToFollow.recordType, listRecordToFollow.data)
        });
        console.log("applying %d list op%s to token id %d", listOps.length, listOps.length == 1 ? "" : "s", tokenId);
        IEFPListRecords(contracts.listRecords).applyListOps(tokenId, listOpsToBytes(listOps));
    }

    function mintMany(Contracts memory contracts, uint limit) public {
        uint256 totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
        uint end = totalSupply + limit;
        while (totalSupply < end) {
          uint256 tokenId = totalSupply;

          ListOp[] memory listOps = new ListOp[](totalSupply);
          for (uint i = 0; i < listOps.length; i++) {
            ListRecord memory listRecordToFollow = ListRecord({
                version: 0x01,
                recordType: 0x01,
                data: abi.encodePacked(address(uint160(i)))
            });
            listOps[i] = ListOp({
                version: 0x01,
                opcode: 0x01,
                data: abi.encodePacked(listRecordToFollow.version, listRecordToFollow.recordType, listRecordToFollow.data)
            });
          }

          console.log("minting token id %d with nonce %d", totalSupply, totalSupply);
          bytes memory listStorageLocation = makeListStorageLocation(contracts.listRecords, totalSupply);
          EFPListMinter(contracts.listMinter).mintAndSetAsDefaultList(listStorageLocation);
          EFPListRecords(contracts.listRecords).claimListManager(tokenId);
          EFPListRecords(contracts.listRecords).setMetadataValue(
              tokenId,
              "user",
              abi.encodePacked(loadedListNfts[tokenId].listUser)
          );
          totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
          lastTokenId = totalSupply;
          // IEFPListRecords(contracts.listRecords).claimListManager(totalSupply);
          // create a single list op to follow the zero address

          console.log("applying %d list op%s to token id %d", listOps.length, listOps.length == 1 ? "" : "s", tokenId);
          IEFPListRecords(contracts.listRecords).applyListOps(tokenId, listOpsToBytes(listOps));

          totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
        }
    }

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // msg.sender will be set to the address derived from the private key
        // you're using for the transaction, specified in the
        // vm.startBroadcast(deployerPrivateKey) call.
        console.log(Colors.GREEN, "Deployer           :", msg.sender, Colors.ENDC);
        console.log(" nonce              :", vm.getNonce(msg.sender));
        console.log();

        // initialize the contracts
        Contracts memory contracts = loadAll();
        ensurePublicMint(contracts);
        console.log();

        // determine the total number of records
        console.log("Loading list NFTs...");
        loadListNFTsCsv(vm.readFile("scripts/data/demo-list-nfts.csv"));
        console.log("Loading list ops...");
        loadListOpsCsv(vm.readFile("scripts/data/demo-list-ops.csv"));
        // parseListOps();

        // add all list ops to ListRecords
        uint256 initialTotalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
        if (initialTotalSupply <= lastTokenId) {
            mints(contracts);
            uint totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
            Logger.logNFTs(contracts, initialTotalSupply);
            console.log();
            Logger.logListOps(contracts, initialTotalSupply, totalSupply - 1);
        } else {
            // mint one more
            mintMany(contracts, 10);
            Logger.logNFTs(contracts, initialTotalSupply);
            console.log();
        }

        // // print all token ids and owners
        // Logger.logNFTs(contracts, initialTotalSupply);
        // console.log();
        // Logger.logListOps(contracts, initialTotalSupply, totalSupply - 1);

        vm.stopBroadcast();
    }
}
