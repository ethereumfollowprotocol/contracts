// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BaseLists} from "./BaseLists.sol";
import {IListRegistry} from "./IListRegistry.sol";
import {ListRecord} from "./ListRecord.sol";

/**
 * @title Lists
 * @notice This contract manages a list of records for each EFP List NFT,
 * providing functionalities to append, delete, and retrieve records. It
 * supports soft deletions, meaning the records are marked as deleted but not
 * actually removed from storage.
 */
contract Lists is BaseLists {

    IListRegistry public listRegistry;

    constructor(IListRegistry listRegistry_) {
        // stubbed for now
        listRegistry = listRegistry_;
    }

    /**
     * Restricts access to the owner of the specified token.
     * @param tokenId The ID of the token whose owner is to be checked.
     */
    modifier onlyTokenOwner(uint tokenId) override {
        // stubbed for now
        require(listRegistry.getManager(tokenId) == msg.sender, "Only EFP List Manager can call this function");
        _;
    }
}
