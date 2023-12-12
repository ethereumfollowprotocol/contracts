// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/ecdsa/ECDSASignatureVerifier.sol";

contract ECDSASignatureVerifierTest is Test {
    function testVerify() public {
        string memory message = "Hello, World!";
        bytes memory messageBytes = abi.encodePacked(message);
        // bytes32 signatureHash = ECDSASignatureVerifier.makeSignatureHash(messageBytes);

        // wallet = ethers.Wallet.fromMnemonic('test test test test test test test test test test test junk', "m/44'/60'/0'/0/0")
        // messageHash = keccak256(toUtf8Bytes('Hello, World!'))
        // signature = joinSignature(wallet._signingKey.signDigest(messageHash))
        bytes
            memory signature = hex"535bfb2a265055407f46c96790966693eb57087d260ffde8572bdad07f95a1af11535b04b689bfd308fe89f6abfd332b28dee0e96e1ced1ee8298c8d26adfde21c";

        // test test test test test test test test test test test junk
        address expectedSigner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

        address recoveredSigner = ECDSASignatureVerifier.verify(messageBytes, signature);
        assertEq(recoveredSigner, expectedSigner, "Signers don't match");
    }
}
