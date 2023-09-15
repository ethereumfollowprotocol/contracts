// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

library Utils {
    function uintToString(uint256 v) internal pure returns (string memory) {
        if (v == 0) return "0";

        uint256 maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint256 i = 0;
        while (v != 0) {
            uint8 remainder = uint8(v % 10);
            v = v / 10;
            reversed[i++] = bytes1(48 + remainder);
        }
        bytes memory s = new bytes(i);
        for (uint256 j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        return string(s);
    }
}

/**
 * @dev Library for verifying signatures using EIP-191.
 */
library EIP191SignatureVerifier {
    using Utils for uint256;

    /**
     * @dev Generates a keccak256 hash of the provided message.
     * @param message The message data to be hashed.
     * @return The keccak256 hash of the message.
     */
    function makeSignatureHash(bytes memory message) public pure returns (bytes32) {
        bytes memory lengthAsBytes = bytes(Utils.uintToString(message.length));
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", lengthAsBytes, message));
    }


    /**
     * @dev Verifies the signer of the provided message using the provided signature.
     * @param message The original message data that was signed.
     * @param signature The signature data (composed of r, s, v values).
     * @return Address of the signer.
     */
    function verify(bytes memory message, bytes memory signature) internal pure returns(address) {
        bytes32 hash = makeSignatureHash(message);
        address signer = ECDSA.recover(hash, signature);
        return signer;
    }
}
