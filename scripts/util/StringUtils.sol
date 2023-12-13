// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";

library StringUtils {
    function substring(string memory str, uint256 startIndex, uint256 endIndex) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    // Helper function to convert a single byte to a hex string
    function byteToHexString(uint8 b) internal pure returns (string memory) {
        bytes memory hexString = new bytes(2);
        bytes memory hexChars = "0123456789abcdef";

        hexString[0] = hexChars[uint8(b) >> 4];
        hexString[1] = hexChars[uint8(b) & 0x0f];

        return string(hexString);
    }

    function bytesToHexString(bytes memory data) public pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    function bytesToHexStringWithoutPrefix(bytes memory data) public pure returns (string memory) {
        string memory hexString = bytesToHexString(data);
        return substring(hexString, 2, bytes(hexString).length);
    }

    function hexStringToBytes(string memory s) internal view returns (bytes memory) {
      // s is of form "0x1234..."
      // need to first check the leading two characters
      require(bytes(s)[0] == "0" && bytes(s)[1] == "x", "hexstringToBytes: string must be of form 0x1234...");

      // should have even number of characters minus the leading "0x"
      require(bytes(s).length % 2 == 0, "hexstringToBytes: string must have even number of characters");

      // now iterate through each pair of characters, converting
      bytes memory bytes_array = new bytes((bytes(s).length - 2) / 2);
      for (uint256 i = 2; i < bytes(s).length; i += 2) {
          uint8 msb = uint8(bytes(s)[i]);
          uint8 lsb = uint8(bytes(s)[i + 1]);
          bytes_array[i / 2 - 1] = bytes1(16 * _hexCharToUint(msb) + _hexCharToUint(lsb));
      }
      return bytes_array;
    }

    function _hexCharToUint(uint8 c) internal pure returns (uint8) {
      if (bytes1(c) >= bytes1("0") && bytes1(c) <= bytes1("9")) {
          return c - uint8(bytes1("0"));
      }
      if (bytes1(c) >= bytes1("a") && bytes1(c) <= bytes1("f")) {
          return 10 + c - uint8(bytes1("a"));
      }
      if (bytes1(c) >= bytes1("A") && bytes1(c) <= bytes1("F")) {
          return 10 + c - uint8(bytes1("A"));
      }
      revert("hexCharToUint: invalid character");
    }

    function stringToUint(string memory s) internal pure returns (uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint8 temp = uint8(b[i]) - 48;
            result = result * 10 + temp;
        }
        return result;
    }

    function stringToAddress(string memory s) internal pure returns (address) {
        bytes memory b = bytes(s);
        uint160 result = 0;
        for (uint256 i = 2; i < 42; i++) {
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
}
