// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {console} from 'lib/forge-std/src/console.sol';
import {Script} from 'lib/forge-std/src/Script.sol';
import {Strings} from 'lib/openzeppelin-contracts/contracts/utils/Strings.sol';
import {IERC721Enumerable} from 'lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol';

import {BytesUtils} from './util/BytesUtils.sol';
import {Colors} from './util/Colors.sol';
import {ContractConfigs} from './util/ContractConfigs.sol';
import {Contracts} from './util/Contracts.sol';
import {CSVUtils} from './util/CSVUtils.sol';
import {Deployer} from './util/Deployer.sol';
import {ListOpUtils} from './util/ListOpUtils.sol';
import {Logger} from './util/Logger.sol';
import {StringUtils} from './util/StringUtils.sol';

import {EFPAccountMetadata} from '../src/EFPAccountMetadata.sol';
import {EFPListMinter} from '../src/EFPListMinter.sol';
import {EFPListRegistry} from '../src/EFPListRegistry.sol';
import {EFPListRecords} from '../src/EFPListRecords.sol';
import {IEFPListRegistry} from '../src/interfaces/IEFPListRegistry.sol';
import {IEFPListRecords} from '../src/interfaces/IEFPListRecords.sol';
import {ListOp} from '../src/types/ListOp.sol';
import {ListRecord} from '../src/types/ListRecord.sol';

import {ListNFTsCsvLoader} from './util/ListNFTsCsvLoader.sol';
import {ListOpsCsvLoader} from './util/ListOpsCsvLoader.sol';

/**
 * @notice This script deploys the EFP contracts and initializes them.
 */
contract MintScript is Script, ListNFTsCsvLoader, ListOpsCsvLoader, Deployer {
  using Strings for uint256;
  using ListOpUtils for ListOp;
  ListOp[] public listOpsToMint;

  function setUp() public {
    // Any setup needed before deployment
  }

  function ensurePublicMint(Contracts memory contracts) public {
    console.log(' totalSupply        :', IERC721Enumerable(contracts.listRegistry).totalSupply());

    IEFPListRegistry.MintState mintState = IEFPListRegistry(contracts.listRegistry).getMintState();
    string memory s = ' Mint state         : ';
    if (mintState == IEFPListRegistry.MintState.Disabled) {
      s = string.concat(s, 'Disabled');
    } else if (mintState == IEFPListRegistry.MintState.OwnerOnly) {
      s = string.concat(s, 'OwnerOnly');
    } else if (mintState == IEFPListRegistry.MintState.PublicMint) {
      s = string.concat(s, 'PublicMint');
    } else if (mintState == IEFPListRegistry.MintState.PublicBatch) {
      s = string.concat(s, 'PublicBatch');
    } else {
      revert('Unknown mint state');
    }

    IEFPListRegistry.MintState desired = IEFPListRegistry.MintState.PublicMint;
    if (mintState != desired) {
      IEFPListRegistry(contracts.listRegistry).setMintState(desired);
      s = string.concat(s, ' -> ', Colors.GREEN, 'PublicMint', Colors.ENDC);
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

  function _getChainId() internal view returns (uint256) {
    uint256 id;
    assembly {
      id := chainid()
    }
    return id;
  }

  // Generalized function to convert bytes to uint256 with a given offset
  function _bytesToUint(bytes memory data, uint256 offset) internal pure returns (uint256) {
    require(data.length >= offset + 32, 'Data too short');
    uint value;
    assembly {
      value := mload(add(data, add(32, offset)))
    }
    return value;
  }

  // Helper function to convert bytes to address with a given offset
  function _bytesToAddress(bytes memory data, uint256 offset) internal pure returns (address addr) {
    require(data.length >= offset + 20, 'Data too short');
    assembly {
      // Extract 20 bytes from the specified offset
      addr := mload(add(add(data, 20), offset))
      // clear the 12 least significant bits of the address
      addr := and(addr, 0x000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
    }
    return addr;
  }

  function makeListStorageLocation(address listRecordsAddress, uint nonce) private view returns (bytes memory) {
    console.log('listRecordsAddress:                                                 %s', listRecordsAddress);
    uint8 VERSION = 1;
    uint8 LIST_LOCATION_TYPE = 1;
    bytes memory listStorageLocation = abi.encodePacked(
      VERSION,
      LIST_LOCATION_TYPE,
      _getChainId(),
      listRecordsAddress,
      nonce
    );
    return listStorageLocation;
  }

  function mints(Contracts memory contracts) public {
    uint256 totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
    for (uint256 tokenId = totalSupply; tokenId <= lastTokenId; tokenId++) {
      console.log('minting token id %d with nonce %d', tokenId, tokenId);
      bytes memory listStorageLocation = makeListStorageLocation(contracts.listRecords, tokenId);
      EFPListMinter(contracts.listMinter).easyMintTo(loadedListNfts[tokenId].listUser, listStorageLocation);
      // claim list manager
      // EFPListRecords(contracts.listRecords).claimListManager(tokenId);
      // EFPListRecords(contracts.listRecords).setMetadataValue(
      //     tokenId,
      //     "user",
      //     abi.encodePacked(loadedListNfts[tokenId].listUser)
      // );
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
    console.log('minting token id %d with nonce %d', totalSupply, totalSupply);
    bytes memory listStorageLocation = makeListStorageLocation(contracts.listRecords, totalSupply);
    EFPListMinter(contracts.listMinter).easyMint(listStorageLocation);
    // EFPListRecords(contracts.listRecords).claimListManager(tokenId);
    // EFPListRecords(contracts.listRecords).setMetadataValue(
    //     tokenId,
    //     "user",
    //     abi.encodePacked(loadedListNfts[tokenId].listUser)
    // );
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
    console.log('applying %d list op%s to token id %d', listOps.length, listOps.length == 1 ? '' : 's', tokenId);
    IEFPListRecords(contracts.listRecords).applyListOps(tokenId, listOpsToBytes(listOps));
  }

  function mintMany(Contracts memory contracts, uint limit) public {
    uint256 totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
    uint end = totalSupply + limit;
    while (totalSupply < end) {
      uint256 tokenId = totalSupply;
      address listUser = address(uint160(tokenId));
      if (listUser == address(0x0)) {
        listUser = address(uint160(0xdead));
      }

      for (uint i = listOpsToMint.length; i < totalSupply; i++) {
        ListRecord memory listRecordToFollow = ListRecord({
          version: 0x01,
          recordType: 0x01,
          data: abi.encodePacked(address(uint160(i)))
        });
        listOpsToMint.push(
          ListOp({
            version: 0x01,
            opcode: 0x01,
            data: abi.encodePacked(listRecordToFollow.version, listRecordToFollow.recordType, listRecordToFollow.data)
          })
        );
      }

      bytes memory listStorageLocation = makeListStorageLocation(contracts.listRecords, totalSupply);
      console.log('easyMintTo token id %d with nonce %d', totalSupply, totalSupply);
      EFPListMinter(contracts.listMinter).easyMintTo(listUser, listStorageLocation);
      // EFPListRecords(contracts.listRecords).claimListManager(tokenId);
      // EFPListRecords(contracts.listRecords).setMetadataValue(
      //     tokenId,
      //     "user",
      //     abi.encodePacked(listUser)
      // );
      totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
      lastTokenId = totalSupply;
      // IEFPListRecords(contracts.listRecords).claimListManager(totalSupply);
      // create a single list op to follow the zero address

      console.log(
        'applying %d list op%s to token id %d',
        listOpsToMint.length,
        listOpsToMint.length == 1 ? '' : 's',
        tokenId
      );
      bytes[] memory listOpsToMintBytes = listOpsToBytes(listOpsToMint);
      // call applyListOps but restrict to a max size of 500 per batch
      uint256 maxBatchSize = 100;
      uint256 batchCount = listOpsToMintBytes.length / maxBatchSize;
      for (uint256 batch = 0; batch < batchCount; batch++) {
        // slice batch
        uint startIndex = batch * maxBatchSize;
        uint endIndex = startIndex + maxBatchSize;
        if (endIndex > listOpsToMintBytes.length) {
          endIndex = listOpsToMintBytes.length;
        }
        bytes[] memory batchListOps = new bytes[](endIndex - startIndex);
        for (uint i = startIndex; i < endIndex; i++) {
          batchListOps[i - startIndex] = listOpsToMintBytes[i];
        }
        IEFPListRecords(contracts.listRecords).applyListOps(tokenId, batchListOps);
      }
      totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
    }
  }

  function getMintInitialTotalSupply() public view returns (uint256) {
    uint mintInitialTotalSupply = vm.envUint('MINT_INITIAL_TOTAL_SUPPLY');
    if (mintInitialTotalSupply == 0) {
      revert('MINT_INITIAL_TOTAL_SUPPLY must be greater than 0');
    }
    return mintInitialTotalSupply;
  }

  function run() public {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    uint mintInitialTotalSupply = getMintInitialTotalSupply();

    // msg.sender will be set to the address derived from the private key
    // you're using for the transaction, specified in the
    // vm.startBroadcast(deployerPrivateKey) call.
    console.log(Colors.GREEN, 'Deployer           :', msg.sender, Colors.ENDC);
    console.log(' nonce              :', vm.getNonce(msg.sender));
    console.log();

    // initialize the contracts
    Contracts memory contracts = loadAll();
    ensurePublicMint(contracts);
    console.log();

    // determine the total number of records
    console.log('Loading list NFTs...');
    loadListNFTsCsv(vm.readFile('scripts/data/demo-list-nfts.csv'));
    console.log('Loading list ops...');
    loadListOpsCsv(vm.readFile('scripts/data/demo-list-ops.csv'));
    // parseListOps();

    // add all list ops to ListRecords
    uint256 initialTotalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
    if (initialTotalSupply <= lastTokenId) {
      mints(contracts);
      uint totalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();
      Logger.logNFTs(contracts, initialTotalSupply);
      console.log();
      Logger.logListOps(contracts, initialTotalSupply, totalSupply - 1);
    }
    uint postCsvMintsTotalSupply = IERC721Enumerable(contracts.listRegistry).totalSupply();

    if (postCsvMintsTotalSupply < mintInitialTotalSupply) {
      // mint one more
      mintMany(contracts, mintInitialTotalSupply - postCsvMintsTotalSupply);
    }
    Logger.logNFTs(contracts, postCsvMintsTotalSupply);
    console.log();

    // // print all token ids and owners
    // Logger.logNFTs(contracts, initialTotalSupply);
    // console.log();
    // Logger.logListOps(contracts, initialTotalSupply, totalSupply - 1);

    vm.stopBroadcast();
  }
}
