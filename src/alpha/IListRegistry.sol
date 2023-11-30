// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { ListStorageLocation } from './ListStorageLocation.sol';
import { IListRegistry } from './IListRegistry.sol';

/**
 * @title ListRegistry
 * @notice A registry connecting token IDs with data such as managers, users, and list locations.
 */
interface IListRegistry {
    ///////////////////////////////////////////////////////////////////////////
    // Mint
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Mints a new token.
    function mint() external;

    /// @notice Mints a new token to the given address.
    function mintTo(address to) external;

    ///////////////////////////////////////////////////////////////////////////
    // List Location
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Fetches the list location associated with a specific token.
     * @param tokenId The ID of the token.
     * @return The list location.
     */
    function getListStorageLocation(
        uint tokenId
    ) external view returns (ListStorageLocation memory);

    /**
     * @notice Associates a token with a list location.
     * @param tokenId The ID of the token.
     * @param contractAddress The contract address to be associated with the token.
     */
    function setListStorageLocationL1(
        uint tokenId,
        address contractAddress
    ) external;

    ///////////////////////////////////////////////////////////////////////////
    // Manager
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Fetches the manager associated with a specific token.
     * @param tokenId The ID of the token.
     * @return The Ethereum address of the manager.
     */
    function getManager(uint tokenId) external view returns (address);

    /**
     * @notice Sets the manager for a specific token.
     * @param tokenId The ID of the token.
     * @param managerAddress The Ethereum address of the manager.
     */
    function setManager(uint tokenId, address managerAddress) external;

    ///////////////////////////////////////////////////////////////////////////
    // User
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Fetches the user associated with a specific token.
     * @param tokenId The ID of the token.
     * @return The Ethereum address of the user.
     */
    function getUser(uint tokenId) external view returns (address);

    /**
     * @notice Sets the user for a specific token.
     * @param tokenId The ID of the token.
     * @param userAddress The Ethereum address of the user.
     */
    function setUser(uint tokenId, address userAddress) external;
}
