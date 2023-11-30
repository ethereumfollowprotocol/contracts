// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import 'forge-std/Script.sol';
import { DeletableListEntry } from '../../src/alpha/ArrayLists.sol';
import { ListRecord } from '../../src/alpha/ListRecord.sol';
import { ListRegistry } from '../../src/alpha/ListRegistry.sol';
import { NonceArrayLists } from '../../src/alpha/NonceArrayLists.sol';

struct CsvRecords {
    uint256 lastTokenId;
    mapping(uint256 => ListRecord[]) recordsMapping;
}

contract EFPScript is Script {
    uint8 constant VERSION = 1;
    uint8 constant LIST_RECORD_TYPE_RAW_ADDRESS = 1;

    ListRegistry listRegistry;
    NonceArrayLists nonceArrayLists;

    uint lastTokenId = 0;
    mapping(uint256 => ListRecord[]) public recordsMapping;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
        vm.startBroadcast(deployerPrivateKey);

        listRegistry = new ListRegistry();
        nonceArrayLists = new NonceArrayLists();

        parseCsv(readCSVFile('scripts/lists.csv'));

        for (uint tokenId = 0; tokenId <= lastTokenId; tokenId++) {
            console.log('Minting EFP List NFT #%d', tokenId);
            listRegistry.mint();
            nonceArrayLists.claimListManager(tokenId);

            ListRecord[] memory records = recordsMapping[tokenId];
            console.log(
                'Appending %d records to EFP List NFT #%d',
                records.length,
                tokenId
            );
            // append the records defined in the csv
            for (uint j = 0; j < records.length; j++) {
                ListRecord memory record = records[j];
                nonceArrayLists.appendRecord(
                    tokenId,
                    record.version,
                    record.recordType,
                    record.data
                );
            }

            // read back data
            uint numRecords = nonceArrayLists.getRecordCount(tokenId);
            console.log(
                'EFP List NFT #%d    nonce: %d    numRecords: %s',
                tokenId,
                tokenId,
                numRecords
            );
            if (numRecords == 0) {
                continue;
            }
            DeletableListEntry[] memory recordsInRange = nonceArrayLists
                .getRecordsInRange(tokenId, 0, numRecords - 1);
            for (uint j = 0; j < recordsInRange.length; j++) {
                logRecord(j, recordsInRange[j]);
            }
        }

        vm.stopBroadcast();
    }

    function readCSVFile(
        string memory filePath
    ) public view returns (string memory) {
        return vm.readFile(filePath);
    }

    // Helper function to parse the CSV and populate the recordsMapping
    function parseCsv(string memory csv) internal {
        string[] memory lines = split(csv, '\n');
        lastTokenId = 0; // Initialize lastTokenId to 0

        for (uint i = 1; i < lines.length; i++) {
            // Start from 1 to skip the header
            string memory line = lines[i];
            // Skip empty lines
            if (bytes(line).length == 0) {
                continue;
            }
            string[] memory values = split(lines[i], ',');

            uint256 efp_nft_token_id = stringToUint(values[0]);

            console.log(
                'i=%d, require(efp_nft_token_id=%d >= %d=lastTokenId, "tokenIds are not monotonically increasing");',
                i,
                efp_nft_token_id,
                lastTokenId
            );
            require(
                efp_nft_token_id >= lastTokenId,
                'tokenIds are not monotonically increasing'
            );

            uint256 nonce = stringToUint(values[1]);
            uint256 record_num = stringToUint(values[2]);

            require(
                efp_nft_token_id == nonce,
                'efp_nft_token_id does not match nonce'
            );
            require(
                record_num == recordsMapping[efp_nft_token_id].length,
                'record_num is not sequential'
            );

            uint8 version = uint8(stringToUint(values[3]));
            uint8 list_record_type = uint8(stringToUint(values[4]));
            bytes memory data = abi.encodePacked(parseAddress(values[5]));

            ListRecord memory record = ListRecord({
                version: version,
                recordType: list_record_type,
                data: data
            });

            recordsMapping[efp_nft_token_id].push(record);
            console.log(
                'LOADED EFP NFT #%d record #%d as %s',
                efp_nft_token_id,
                record_num,
                bytesToHexString(data)
            );

            lastTokenId = efp_nft_token_id; // Update lastTokenId after processing the line
        }
    }

    function split(
        string memory s,
        string memory delimiter
    ) internal pure returns (string[] memory) {
        bytes memory b = bytes(s);
        uint count = 1;
        for (uint i = 0; i < b.length; i++) {
            if (b[i] == bytes(delimiter)[0]) count++;
        }

        string[] memory parts = new string[](count);
        uint j = 0;
        uint start = 0;
        for (uint i = 0; i < b.length; i++) {
            if (b[i] == bytes(delimiter)[0]) {
                parts[j] = new string(i - start);
                bytesCopy(b, start, i - start, bytes(parts[j]), 0);
                start = i + 1;
                j++;
            }
        }
        if (start < b.length) {
            parts[j] = new string(b.length - start);
            bytesCopy(b, start, b.length - start, bytes(parts[j]), 0);
        }

        return parts;
    }

    function stringToUint(string memory s) internal pure returns (uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for (uint i = 0; i < b.length; i++) {
            uint8 temp = uint8(b[i]) - 48;
            result = result * 10 + temp;
        }
        return result;
    }

    function parseAddress(string memory s) internal pure returns (address) {
        bytes memory b = bytes(s);
        uint160 result = 0;
        for (uint i = 2; i < 42; i++) {
            // start from 2 to skip the "0x"
            uint8 temp;
            if (uint8(b[i]) >= 97) {
                // 'a'
                temp = uint8(b[i]) - 87; // 'a' is 97 in ascii and its value in hex is 10
            } else {
                temp = uint8(b[i]) - 48; // '0' is 48 in ascii
            }
            result = uint160(result * 16 + temp);
        }
        return address(result);
    }

    function bytesCopy(
        bytes memory source,
        uint sourceStart,
        uint sourceLength,
        bytes memory destination,
        uint destinationStart
    ) internal pure {
        for (uint i = 0; i < sourceLength; i++) {
            destination[destinationStart + i] = source[sourceStart + i];
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
