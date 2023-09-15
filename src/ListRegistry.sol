// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "lib/ERC721A/contracts/ERC721A.sol";
import {ListStorageLocation} from "./ListStorageLocation.sol";

/**
 * @title ListManager
 * @notice Represents a manager associated with a token.
 */
struct ListManager {
    /// @dev True if this struct has been set, used to distinguish from default zero struct.
    bool isSet;

    /// @dev Ethereum address of the manager.
    address managerAddress;
}

/**
 * @title ListUser
 * @notice Represents a user associated with a token.
 */
struct ListUser {
    /// @dev True if this struct has been set, used to distinguish from default zero struct.
    bool isSet;

    /// @dev Ethereum address of the user.
    address userAddress;
}

/**
 * @title ListRegistry
 * @notice A registry connecting token IDs with data such as managers, users, and list locations.
 */
contract ListRegistry is ERC721A {

    uint8 constant VERSION = 1;

    uint8 constant LIST_LOCATION_L1 = 1;

    mapping(uint => ListStorageLocation) private tokenIdToListStorageLocation;

    mapping(uint => ListManager) private tokenIdToListManager;

    mapping(uint => ListUser) private tokenIdToListUser;

    /// @notice Constructs a new ListRegistry and sets its name and symbol.
    constructor() ERC721A("EFP", "EFP") {}

    /// @notice Mints a new token.
    function mint() public {
        _mint(msg.sender, 1);
    }

    /// @notice Mints a new token to the given address.
    function mintTo(address to) public {
        _mint(to, 1);
    }

    /// @notice Restrict access to the owner of a specific token.
    modifier onlyTokenOwner(uint tokenId) {
        require(ownerOf(tokenId) == msg.sender, "EFP: caller is not the owner");
        _;
    }

    ///////////////////////////////////////////////////////////////////////////
    // List Location
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Fetches the list location associated with a specific token.
     * @param tokenId The ID of the token.
     * @return The list location.
     */
    function getListStorageLocation(uint tokenId) external view returns (ListStorageLocation memory) {
        return tokenIdToListStorageLocation[tokenId];
    }

    /**
     * @notice Associates a token with a list location.
     * @param tokenId The ID of the token.
     * @param contractAddress The contract address to be associated with the token.
     */
    function setListStorageLocationL1(uint tokenId, address contractAddress) external onlyTokenOwner(tokenId) {
        // abi.encodePacked will give a 20 byte representation of the address
        tokenIdToListStorageLocation[tokenId] = ListStorageLocation(VERSION, LIST_LOCATION_L1, abi.encodePacked(contractAddress));
    }

    ///////////////////////////////////////////////////////////////////////////
    // Manager
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Fetches the manager associated with a specific token.
     * @param tokenId The ID of the token.
     * @return The Ethereum address of the manager.
     */
    function getManager(uint tokenId) external view returns (address) {
        ListManager memory manager = tokenIdToListManager[tokenId];

        // distinguish from 0x0000...0000 address
        if (manager.isSet) {
            return manager.managerAddress;
        } else {
            // else default to the owner of the token
            return ownerOf(tokenId);
        }
    }

    /**
     * @notice Sets the manager for a specific token.
     * @param tokenId The ID of the token.
     * @param managerAddress The Ethereum address of the manager.
     */
    function setManager(uint tokenId, address managerAddress) external onlyManagerOrOwner(tokenId) {
        require(ownerOf(tokenId) == msg.sender, "EFP: caller is not the owner");
        tokenIdToListManager[tokenId] = ListManager(true, managerAddress);
    }

    /// @notice Restrict access to the manager of a specific token.
    modifier onlyManager(uint tokenId) {
        require(tokenIdToListManager[tokenId].managerAddress == msg.sender, "EFP: caller is not the manager");
        _;
    }

    /// @notice Restrict access to the owner or manager of a specific token.
    modifier onlyManagerOrOwner(uint tokenId) {
        require(tokenIdToListManager[tokenId].managerAddress == msg.sender || ownerOf(tokenId) == msg.sender, "EFP: caller is not the manager or owner");
        _;
    }

    ///////////////////////////////////////////////////////////////////////////
    // User
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Fetches the user associated with a specific token.
     * @param tokenId The ID of the token.
     * @return The Ethereum address of the user.
     */
    function getUser(uint tokenId) external view returns (address) {
        ListUser memory user = tokenIdToListUser[tokenId];

        // distinguish from 0x0000...0000 address
        if (user.isSet) {
            return user.userAddress;
        } else {
            // else default to the owner of the token
            return ownerOf(tokenId);
        }
    }

    /**
     * @notice Sets the user for a specific token.
     * @param tokenId The ID of the token.
     * @param userAddress The Ethereum address of the user.
     */
    function setUser(uint tokenId, address userAddress) external onlyManagerOrOwner(tokenId) {
        require(ownerOf(tokenId) == msg.sender, "EFP: caller is not the manager");
        tokenIdToListUser[tokenId] = ListUser(true, userAddress);
    }
}
