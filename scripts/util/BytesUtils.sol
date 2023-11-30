// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

library BytesUtils {
    // Helper function to slice bytes array
    function slice(bytes memory data, uint start, uint length) internal pure returns (bytes memory) {
        bytes memory part = new bytes(length);
        for (uint i = 0; i < length; i++) {
            part[i] = data[i + start];
        }
        return part;
    }

    function copy(
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
}
