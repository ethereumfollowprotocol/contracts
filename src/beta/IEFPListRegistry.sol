// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ListStorageLocation} from "./ListStorageLocation.sol";

/**
 * @title EFPListRegistry
 * @notice A registry connecting token IDs with data such as managers, users, and list locations.
 */
interface IEFPListRegistry {

    ///////////////////////////////////////////////////////////////////////////
    // Events
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Emitted when a list storage location is set
    event ListStorageLocationChange(uint indexed tokenId, ListStorageLocation listStorageLocation);

    /// @notice Emitted when a list user is set
    event ListUserChange(uint indexed tokenId, address listUser);

    ///////////////////////////////////////////////////////////////////////////
    // Mint
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Mints a new token.
    function mint() external;

    /**
     * @notice Mints a new token to the given address.
     * @param to The address to mint the token to.
    */
    function mintTo(address to) external;

    /// @notice Mints a new token to the given address.
    function mintBatch(uint num) external;

    /// @notice Mints a new token to the given address.
    function mintBatchTo(address to, uint num) external;

    // ///////////////////////////////////////////////////////////////////////////
    // // List Location
    // ///////////////////////////////////////////////////////////////////////////

    // /**
    //  * @notice Fetches the list location associated with a specific token.
    //  * @param tokenId The ID of the token.
    //  * @return The list location.
    //  */
    // function getListStorageLocation(uint tokenId) external view returns (ListStorageLocation memory) ;

    // /**
    //  * @notice Associates a token with a list location.
    //  * @param tokenId The ID of the token.
    //  * @param listStorageLocation The new list storage location to be associated with the token.
    //  */
    // function setListStorageLocation(uint tokenId, ListStorageLocation calldata listStorageLocation) external;

    // ///////////////////////////////////////////////////////////////////////////
    // // User
    // ///////////////////////////////////////////////////////////////////////////

    // /**
    //  * @notice Fetches the user associated with a specific token.
    //  * @param tokenId The ID of the token.
    //  * @return The Ethereum address of the user.
    //  */
    // function getUser(uint tokenId) external view returns (address);

    // /**
    //  * @notice Sets the user for a specific token.
    //  * @param tokenId The ID of the token.
    //  * @param userAddress The Ethereum address of the user.
    //  */
    // function setUser(uint tokenId, address userAddress) external;
}
