// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ListRecord} from "../../src/ListRecord.sol";

library ListRecordUtils {
    function slice(bytes memory data, uint256 start, uint256 length) internal pure returns (bytes memory) {
        bytes memory result = new bytes(length);
        for (uint256 i = 0; i < length; i++) {
            result[i] = data[start + i];
        }
        return result;
    }

    function encode(ListRecord memory record) internal pure returns (bytes memory) {
        bytes memory result = new bytes(2 + record.data.length);
        result[0] = bytes1(record.version);
        result[1] = bytes1(record.recordType);
        for (uint256 i = 0; i < record.data.length; i++) {
            result[2 + i] = record.data[i];
        }
        return result;
    }
}
