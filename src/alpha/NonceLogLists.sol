// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { ABaseLists } from './ABaseLists.sol';
import { LogLists } from './LogLists.sol';
import { IListRegistry } from './IListRegistry.sol';
import { ListRecord } from './ListRecord.sol';
import { NonceListManager } from './NonceListManager.sol';

/**
 * @title NonceLogLists
 * @notice Manages records for each EFP List NFT, providing functionalities for record
 * manipulation. Employs an event-based mechanism, emitting events for each list operation.
 */
contract NonceLogLists is LogLists, NonceListManager {
    /**
     * @notice A modifier that ensures only the manager of a specific token can access the decorated function.
     * @param nonce The nonce of the list.
     * @dev Throws an error if the caller isn't the manager of the provided nonce.
     */
    modifier onlyListManager(uint nonce)
        override(ABaseLists, NonceListManager) {
        _onlyListManager(nonce);
        _;
    }
}
