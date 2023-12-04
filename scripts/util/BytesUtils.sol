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

    function toAddress(bytes memory data, uint start) internal pure returns (address) {
        require(data.length >= start + 20, "BytesUtils: data is too short");
        address result;
        assembly {
            // the layout of the bytes is as follows:
            // first 32 bytes: length of bytes array
            // second 32 bytes: offset at which the data starts
            // ...
            result := mload(add(add(data, 0x20), start))
            // shift right to align the address correctly
            result := shr(96, result)
        }
        return result;
    }

    function toUint256(bytes memory data, uint start) internal pure returns (uint256) {
        require(data.length >= start + 32, "BytesUtils: data is too short");
        uint256 result;
        assembly {
            result := mload(add(add(data, 0x20), start))
        }
        return result;
    }
}
