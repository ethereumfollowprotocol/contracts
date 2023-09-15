// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BaseLists} from "./BaseLists.sol";
import {IListRegistry} from "./IListRegistry.sol";
import {ListRecord} from "./ListRecord.sol";

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
 * @title Lists
 * @notice This contract manages a list of records for each EFP List NFT,
 * providing functionalities to append, delete, and retrieve records. It
 * supports soft deletions, meaning the records are marked as deleted but not
 * actually removed from storage.
 */
contract ListsWithOffchainManager is BaseLists {

    address public signer;

    mapping(uint tokenId => ListManager) public managers;

    constructor(address signer_) {
        signer = signer_;
    }

    /**
     * Restricts access to the manager of the specified token.
     * @param tokenId The ID of the token whose manager is to be checked.
     */
    modifier onlyListManager(uint tokenId) override {
        ListManager memory manager = managers[tokenId];
        require(manager.isSet && manager.managerAddress == msg.sender, "Only EFP List Manager can call this function");
        _;
    }
}
