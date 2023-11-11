// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ArrayLists} from "./ArrayLists.sol";
import {IListRegistry} from "./IListRegistry.sol";
import {ListRecord} from "./ListRecord.sol";
import "../../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

import "../../lib/forge-std/src/console.sol";

/**
 * @title ListManager
 * @notice A structure representing the manager associated with a specific EFP List NFT.
 * @dev Contains the Ethereum address of the manager and a flag indicating the initialization status of the structure.
 */
struct ListManager {
    /// @notice Initialization flag for the structure.
    bool isSet;

    /// @notice Ethereum address of the manager.
    address managerAddress;
}

/**
 * @title ListsWithOffchainManager
 * @notice Manages records for each EFP List NFT, providing functionalities for record
 * manipulation. Employs a soft deletion mechanism, flagging records as deleted without removing them from storage.
 * @dev Utilizes offchain signatures to authenticate manager's actions, bypassing the EIP-191 standard.
 */
contract ListsWithOffchainManager is ArrayLists {

    /// @notice The Ethereum address responsible for offchain signing.
    address public signer;

    /// @notice A mapping from a token ID to its associated manager.
    mapping(uint nonce => ListManager) public managers;

    /**
     * @notice Initializes the contract and sets the provided address as the offchain signer.
     * @param signer_ The Ethereum address of the offchain signer.
     */
    constructor(address signer_) {
        signer = signer_;
    }

    function getSigner() external view returns (address) {
        return signer;
    }

    /**
     * @notice A modifier that ensures only the manager of a specific token can access the decorated function.
     * @param nonce The nonce being checked.
     * @dev Throws an error if the caller isn't the manager of the provided token ID.
     */
    modifier onlyListManager(uint nonce) override {
        ListManager memory manager = managers[nonce];
        require(manager.isSet && manager.managerAddress == msg.sender, "Only EFP List Manager can call this function");
        _;
    }

    /**
     * @notice Validates the provided offchain signature to verify the manager's authority over a token.
     * @param nonce The nonce whose manager's authority needs validation.
     * @param manager The Ethereum address of the manager claiming authority over the token.
     * @param signature The offchain signature provided for validation.
     * @return Returns 'true' if the provided signature is valid for the claimed manager, otherwise returns 'false'.
     * @dev Constructs a unique message for the token and manager, then checks if the recovered signer's address
     * from the signature matches the caller's address.
     */
    function proveListManagerWithOffchainSignature(uint nonce, address manager, bytes calldata signature) internal view returns (bool) {
        // Create a unique message for validation using the following structure:
        // - Start with a 0x19 byte ensuring the data isn't considered valid RLP.
        // - Follow with version 0x00 and a 3-byte "EFP" prefix.
        // - Attach the token ID (32 bytes)
        // - then "manager" (7 bytes)
        // - and the claimed manager's address (20 bytes).
        // The resulting 64-byte message is optimized for efficient gas usage during signature verification.

        bytes memory message = makeSignatureMessage(nonce, manager);
        bytes32 messageHash = keccak256(message);
        address recoveredSigner = ECDSA.recover(messageHash, signature);

        return recoveredSigner == signer;
    }

    function makeSignatureMessage(uint nonce, address manager) internal pure returns (bytes memory) {
        bytes memory message = abi.encodePacked(
            "\x19\x00EFP",
            bytes32(nonce),
            "manager",
            bytes20(manager)
        );
        return message;
    }

    /**
     * @notice Allows a manager to claim authority over a token using an offchain signature.
     * @param nonce The nonce for which the manager is claiming authority over.
     * @param signature The offchain signature provided to prove the manager's claim.
     * @dev This function first verifies the offchain signature for the manager's authority
     * using the `proveListManagerWithOffchainSignature` function. If the verification succeeds,
     * the manager's address (which is the address of the caller) is set as the manager for the token.
     * The token's manager data is then updated in the `managers` mapping.
     */
    function claimListManagerWithOffchainSignature(uint nonce, bytes calldata signature) external {
        require(proveListManagerWithOffchainSignature(nonce, msg.sender, signature), "Invalid signature");
        managers[nonce] = ListManager({
            isSet: true,
            managerAddress: msg.sender
        });
    }

    function getListManager(uint nonce) external view returns (address) {
        return managers[nonce].managerAddress;
    }

}
