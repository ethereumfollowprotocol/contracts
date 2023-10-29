// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ABaseLists} from "./ABaseLists.sol";
import {MappingLists} from "./MappingLists.sol";
import {IListRegistry} from "./IListRegistry.sol";
import {ListRecord} from "./ListRecord.sol";
import {NonceListManager} from "./NonceListManager.sol";

/**
 * @title NonceMappingLists
 * @notice Manages records for each EFP List NFT, providing functionalities for record
 * manipulation. Employs a soft deletion mechanism, flagging records as deleted without removing them from storage.
 */
contract NonceMappingLists is MappingLists, NonceListManager {

    /**
     * @notice A modifier that ensures only the manager of a specific token can access the decorated function.
     * @param nonce The nonce of the list.
     * @dev Throws an error if the caller isn't the manager of the provided nonce.
     */
    modifier onlyListManager(uint nonce) override(ABaseLists, NonceListManager) {
        _onlyListManager(nonce);
        _;
    }

}
