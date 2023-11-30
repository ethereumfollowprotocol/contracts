// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IListRegistry} from "./IListRegistry.sol";
import {ListRecord} from "./ListRecord.sol";

/**
 * @title NonceListManager
 * @notice This contract manages the association between nonces and their respective managers.
 * It allows an entity to claim a nonce, set a manager for a nonce, and fetch the manager of a nonce.
 * @dev The contract employs a first-come-first-serve model where the first entity to claim a nonce becomes its manager.
 */
contract NonceListManager {
    /// @notice A mapping that associates each nonce with its manager's address.
    mapping(uint nonce => address) public managers;

    /**
     * @notice A modifier that restricts access to functions only for the manager of a specific nonce.
     * @param nonce The nonce associated with a list.
     * @dev Throws an error if the caller is not the manager of the specified nonce.
     */
    modifier onlyListManager(uint nonce) virtual {
        _onlyListManager(nonce);
        _;
    }

    function _onlyListManager(uint nonce) internal view {
        require(managers[nonce] == msg.sender, "Not manager");
    }

    /**
     * @notice Enables a manager to claim authority over a nonce.
     * The first entity to claim a nonce becomes its manager.
     * @param nonce The nonce the manager wants to claim.
     * @dev Throws an error if the nonce is already claimed.
     */
    function claimListManager(uint nonce) external {
        // First-come-first-serve basis for claiming nonce
        require(managers[nonce] == address(0), "Nonce already claimed");
        managers[nonce] = msg.sender;
    }

    /**
     * @notice Enables the current manager to set or change the manager of a nonce.
     * @param nonce The nonce whose manager needs to be set or changed.
     * @param manager The address of the new manager.
     * @dev Throws an error if the caller is not the current manager of the specified nonce.
     */
    function setListManager(uint nonce, address manager) external onlyListManager(nonce) {
        managers[nonce] = manager;
    }

    /**
     * @notice Retrieves the manager associated with a specific nonce.
     * @param nonce The nonce whose manager needs to be fetched.
     * @return The address of the manager associated with the specified nonce.
     */
    function getListManager(uint nonce) external view returns (address) {
        return managers[nonce];
    }
}
