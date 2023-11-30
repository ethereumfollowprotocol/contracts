// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { BytesUtils } from './BytesUtils.sol';

library CSVUtils {
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
                BytesUtils.copy(b, start, i - start, bytes(parts[j]), 0);
                start = i + 1;
                j++;
            }
        }
        if (start < b.length) {
            parts[j] = new string(b.length - start);
            BytesUtils.copy(b, start, b.length - start, bytes(parts[j]), 0);
        }

        return parts;
    }
}
