// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BytesUtils} from "../util/BytesUtils.sol";
import {CSVUtils} from "../util/CSVUtils.sol";
import {StringUtils} from "../util/StringUtils.sol";
import {ListOp} from "../../src/types/ListOp.sol";

contract ListOpsCsvLoader {
    mapping(uint256 => ListOp[]) public loadedListOpsMapping;

    function loadListOpsCsv(string memory csv) internal {
        string[] memory lines = CSVUtils.split(csv, "\n");

        for (uint256 i = 1; i < lines.length; i++) {
            // Start from 1 to skip the header
            string memory line = lines[i];
            // Skip empty lines
            if (bytes(line).length == 0) {
                continue;
            }
            string[] memory values = CSVUtils.split(lines[i], ",");
            uint256 nonce = StringUtils.stringToUint(values[0]);
            string memory listOpHex = values[1];

            bytes memory listOpBytes = StringUtils.hexStringToBytes(listOpHex);
            uint8 listOpVersion = uint8(listOpBytes[0]);
            uint8 listOpCode = uint8(listOpBytes[1]);
            bytes memory listOpData = BytesUtils.slice(listOpBytes, 2, listOpBytes.length - 2);
            ListOp memory listOp = ListOp({version: listOpVersion, opcode: listOpCode, data: listOpData});

            loadedListOpsMapping[nonce].push(listOp);
        }
    }
}
