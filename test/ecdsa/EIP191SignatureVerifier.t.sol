// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/ecdsa/EIP191SignatureVerifier.sol";

contract EIP191SignatureVerifierTest is Test {

    function testVerify() public {
        string memory message = "Hello, World!";

        bytes memory messageBytes = abi.encodePacked(message);
        // bytes32 signatureHash = EIP191SignatureVerifier.makeSignatureHash(messageBytes);

        // await ethers.Wallet.fromMnemonic('test test test test test test test test test test test junk', "m/44'/60'/0'/0/0").signMessage(keccak256(toUtf8Bytes('Hello, World!')))
        bytes memory signature = hex"f6af7bea9e306d226b7b00b5c51a601f1fd18de409b2272f9f2b68c203571b5430ce3ab2344b58191d0c8acb5e5cd7106836ab960e04996adbddb344e37063e81c";

        // test test test test test test test test test test test junk
        address expectedSigner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

        address recoveredSigner = EIP191SignatureVerifier.verify(messageBytes, signature);
        assertEq(recoveredSigner, expectedSigner, "Signers don't match");
    }
}
