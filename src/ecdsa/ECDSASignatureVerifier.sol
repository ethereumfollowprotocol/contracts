// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "../../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

/**
 * @dev Library for verifying signatures using EIP-191.
 */
library ECDSASignatureVerifier {

    /**
     * @dev Generates a keccak256 hash of the provided message.
     * @param message The message data to be hashed.
     * @return The keccak256 hash of the message.
     */
    function makeSignatureHash(bytes memory message) public pure returns (bytes32) {
        return keccak256(message);
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
