// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ABaseLists} from "./ABaseLists.sol";
import {IListRegistry} from "./IListRegistry.sol";
import {ListOperation} from "./ListOperation.sol";
import {ListRecord} from "./ListRecord.sol";

/**
 * @title LogLists
 * @notice This contract manages a list of records for each EFP List NFT,
 * providing functionalities to append, delete, and retrieve records. It
 * supports soft deletions, meaning the records are marked as deleted but not
 * actually removed from storage.
 */
contract LogLists is ABaseLists {
    ///////////////////////////////////////////////////////////////////////////
    // Write APIs
    ///////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////
    // Write - Append
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Appends a record to the end of the list.
     *
     * @param nonce The nonce of the list for which to append.
     * @param version The version number of the record.
     * @param recordType The type identifier of the record.
     * @param data The actual data content of the record.
     */
    function _appendRecord(uint nonce, uint8 version, uint8 recordType, bytes memory data) internal override {
        emit RecordAdded(nonce, keccak256(abi.encode(version, recordType, data)));
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write - Delete
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Marks a record as deleted. This is a soft delete; the record remains but is flagged.
     *
     * @param nonce The nonce of the list for which to delete record.
     * @param recordHash The hash identifier of the record to delete.
     */
    function _deleteRecord(uint nonce, bytes32 recordHash) internal override {
        emit RecordDeleted(nonce, recordHash);
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write - Modify
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Perform a generalized modification to the list.
     *
     * @param nonce The nonce of the list for which to modify records.
     * @param operation The operation to perform.
     */
    function _modifyRecord(uint nonce, ListOperation calldata operation) internal virtual override {
        if (operation.operationType == OPERATION_APPEND) {
            ListRecord memory record = abi.decode(operation.data, (ListRecord));
            _appendRecord(nonce, record.version, record.recordType, record.data);
        } else if (operation.operationType == OPERATION_DELETE) {
            bytes32 recordHash = abi.decode(operation.data, (bytes32));
            _deleteRecord(nonce, recordHash);
        } else {
            revert("Invalid operation type");
        }
    }
}
