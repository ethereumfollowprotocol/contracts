// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ArrayLists} from "./ArrayLists.sol";
import {IListRegistry} from "./IListRegistry.sol";
import {ListRecord} from "./ListRecord.sol";

/**
 * @title Lists
 * @notice This contract manages a list of records for each EFP List NFT,
 * providing functionalities to append, delete, and retrieve records. It
 * supports soft deletions, meaning the records are marked as deleted but not
 * actually removed from storage.
 */
contract Lists is ArrayLists {

    IListRegistry public listRegistry;

    constructor(IListRegistry listRegistry_) {
        listRegistry = listRegistry_;
    }

    /**
     * Restricts access to the manager of the specified token.
     * @param nonce The nonce of the list whose manager is to be checked.
     */
    modifier onlyListManager(uint nonce) override {
        // stubbed for now
        require(listRegistry.getManager(nonce) == msg.sender, "Only EFP List Manager can call this function");
        _;
    }
}
