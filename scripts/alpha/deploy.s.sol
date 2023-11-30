// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import 'forge-std/Script.sol';
import { DeletableListEntry } from '../../src/alpha/ArrayLists.sol';
import { ListRegistry } from '../../src/alpha/ListRegistry.sol';
import { NonceArrayLists } from '../../src/alpha/NonceArrayLists.sol';

contract EFPScript is Script {
    uint8 constant VERSION = 1;
    uint8 constant LIST_RECORD_TYPE_RAW_ADDRESS = 1;

    ListRegistry listRegistry;
    NonceArrayLists nonceArrayLists;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
        vm.startBroadcast(deployerPrivateKey);

        listRegistry = new ListRegistry();
        nonceArrayLists = new NonceArrayLists();

        for (uint i = 0; i < 6; i++) {
            mintAndAddFollowers(i);
        }

        vm.stopBroadcast();
    }

    function mintAndAddFollowers(uint followerCount) internal {
        listRegistry.mint();
        uint totalSupply = listRegistry.totalSupply();
        uint tokenId = totalSupply - 1;

        // claim list manager
        uint nonce = tokenId;
        nonceArrayLists.claimListManager(nonce);

        appendRecords(nonce, followerCount);

        // read back data
        uint numRecords = nonceArrayLists.getRecordCount(nonce);
        console.log(
            'EFP List NFT #%d    nonce: %d    numRecords: %s',
            tokenId,
            nonce,
            numRecords
        );
        DeletableListEntry[] memory records = nonceArrayLists.getRecordsInRange(
            nonce,
            0,
            numRecords - 1
        );
        for (uint i = 0; i < records.length; i++) {
            logRecord(i, records[i]);
        }
    }

    function appendRecords(uint nonce, uint count) internal {
        for (uint i = 0; i < count; i++) {
            nonceArrayLists.appendRecord(
                nonce,
                VERSION,
                LIST_RECORD_TYPE_RAW_ADDRESS,
                abi.encodePacked(address(uint160(i)))
            );
        }
    }

    function logRecord(
        uint num,
        DeletableListEntry memory record
    ) internal view {
        console.log('  record #%d', num);
        console.log('    deleted:    %s', record.deleted);
        console.log('    version:    %d', record.record.version);
        console.log('    recordType: %d', record.record.recordType);
        console.log('    data:       %s', bytesToHexString(record.record.data));
    }

    function bytesToHexString(
        bytes memory data
    ) public pure returns (string memory) {
        bytes memory alphabet = '0123456789abcdef';

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
}
