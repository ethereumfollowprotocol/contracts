// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {MappingLists} from "./MappingLists.sol";
import {IListRegistry} from "./IListRegistry.sol";
import {ListRecord} from "./ListRecord.sol";

/**
 * @title NonceMappingLists
 * @notice Manages records for each EFP List NFT, providing functionalities for record
 * manipulation. Employs a soft deletion mechanism, flagging records as deleted without removing them from storage.
 */
contract NonceMappingLists is MappingLists {

    /// @notice A mapping from a nonce to its associated manager.
    mapping(uint nonce => address) public managers;

    /**
     * @notice A modifier that ensures only the manager of a specific token can access the decorated function.
     * @param nonce The nonce of the list.
     * @dev Throws an error if the caller isn't the manager of the provided nonce.
     */
    modifier onlyListManager(uint nonce) override {
        require(managers[nonce] == msg.sender, "Not manager");
        _;
    }

    /**
     * @notice Allows a manager to claim authority over a token using an offchain signature.
     * @param nonce The nonce to claim.
     */
    function claimListManager(uint nonce) external {
        // first come first serve can claim nonce
        require(managers[nonce] == address(0), "Nonce already claimed");
        managers[nonce] = msg.sender;
    }

    /**
     * @notice Allows a manager to set the manager of a token.
     *
     * @param nonce The nonce of the list.
     * @param manager The manager to set.
     */
    function setListManager(uint nonce, address manager) external onlyListManager(nonce) {
        managers[nonce] = manager;
    }

    /**
     * @notice Fetches the list manager associated with a specific token.
     *
     * @param nonce The nonce of the list.
     * @return The list manager.
     */
    function getListManager(uint nonce) external view returns (address) {
        return managers[nonce];
    }

}
