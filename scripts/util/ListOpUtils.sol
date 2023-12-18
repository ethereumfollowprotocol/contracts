// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Colors} from "./Colors.sol";

import {ListOp} from "../../src/types/ListOp.sol";

library ListOpUtils {
    function slice(bytes memory data, uint256 start, uint256 length) internal pure returns (bytes memory) {
        bytes memory result = new bytes(length);
        for (uint256 i = 0; i < length; i++) {
            result[i] = data[start + i];
        }
        return result;
    }

    function encode(ListOp memory listOp) internal pure returns (bytes memory) {
        bytes memory result = new bytes(2 + listOp.data.length);
        result[0] = bytes1(listOp.version);
        result[1] = bytes1(listOp.opcode);
        for (uint256 i = 0; i < listOp.data.length; i++) {
            result[2 + i] = listOp.data[i];
        }
        return result;
    }

    function description(ListOp memory listOp) internal pure returns (string memory desc) {
        string memory s;

        if (listOp.opcode == 0x01) {
            s = string.concat(Colors.GREEN, "add record   ", Colors.ENDC);
        } else if (listOp.opcode == 0x02) {
            s = string.concat(Colors.RED, "remove record", Colors.ENDC);
        } else if (listOp.opcode == 0x03) {
            s = string.concat("tag '", decodeTag(listOp), "'");
            while (bytes(s).length < 13) {
                s = string.concat(s, " ");
            }
            s = string.concat(Colors.DARK_GREEN, s, Colors.ENDC);
        } else if (listOp.opcode == 0x04) {
            s = string.concat("untag '", decodeTag(listOp), "'");
            while (bytes(s).length < 13) {
                s = string.concat(s, " ");
            }
            s = string.concat(Colors.DARK_RED, s, Colors.ENDC);
        }
        while (bytes(s).length < 16) {
            s = string.concat(s, " ");
        }
        return s;
    }

    function decodeTag(ListOp memory listOp) internal pure returns (string memory) {
        require(listOp.opcode == 0x03 || listOp.opcode == 0x04, "ListOpUtils: invalid code");
        // extract the tag as a UTF-8 string starting from the 23rd byte (index 22-end)
        return string(slice(listOp.data, 22, listOp.data.length - 22));
    }

    function decode(bytes memory data) internal pure returns (ListOp memory) {
        require(data.length >= 2, "ListOpUtils: invalid data");
        return ListOp(uint8(data[0]), uint8(data[1]), slice(data, 2, data.length - 2));
    }
}
