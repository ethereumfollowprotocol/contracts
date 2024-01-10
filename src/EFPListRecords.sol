// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IEFPListMetadata, IEFPListRecords} from "./interfaces/IEFPListRecords.sol";
import {ENSReverseClaimer} from "./lib/ENSReverseClaimer.sol";

/**
 * @title ListMetadata
 *
 * @notice Manages key-value pairs associated with EFP List NFTs.
 *         Provides functionalities for list managers to set and retrieve metadata for their lists.
 */
abstract contract ListMetadata is IEFPListMetadata {
    error NonceAlreadyClaimed(uint256 nonce, address manager);
    // error NotListManager(address manager);

    ///////////////////////////////////////////////////////////////////////////
    // Data Structures
    ///////////////////////////////////////////////////////////////////////////

    /// @dev The key-value set for each token ID
    mapping(uint256 => mapping(string => bytes)) private values;

    /////////////////////////////////////////////////////////////////////////////
    // Helpers
    /////////////////////////////////////////////////////////////////////////////

    function bytesToAddress(bytes memory b) internal pure returns (address) {
        require(b.length == 20, "Invalid length");
        address addr;
        assembly {
            addr := mload(add(b, 20))
        }
        return addr;
    }

    /////////////////////////////////////////////////////////////////////////////
    // Getters
    /////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Retrieves metadata value for token ID and key.
     * @param tokenId The token Id to query.
     * @param key The key to query.
     * @return The associated value.
     */
    function getMetadataValue(uint256 tokenId, string calldata key) external view returns (bytes memory) {
        return values[tokenId][key];
    }

    /**
     * @dev Retrieves metadata values for token ID and keys.
     * @param tokenId The token Id to query.
     * @param keys The keys to query.
     * @return The associated values.
     */
    function getMetadataValues(uint256 tokenId, string[] calldata keys) external view returns (bytes[] memory) {
        uint256 length = keys.length;
        bytes[] memory result = new bytes[](length);
        for (uint256 i = 0; i < length;) {
            string calldata key = keys[i];
            result[i] = values[tokenId][key];
            unchecked {
                ++i;
            }
        }
        return result;
    }

    /////////////////////////////////////////////////////////////////////////////
    // Setters
    /////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Sets metadata records for token ID with the unique key key to value,
     * overwriting anything previously stored for token ID and key. To clear a
     * field, set it to the empty string.
     * @param nonce The nonce corresponding to the list to update.
     * @param key The key to set.
     * @param value The value to set.
     */
    function _setMetadataValue(uint256 nonce, string memory key, bytes memory value) internal {
        values[nonce][key] = value;
        emit UpdateListMetadata(nonce, key, value);
    }

    /**
     * @dev Sets metadata records for token ID with the unique key key to value,
     * overwriting anything previously stored for token ID and key. To clear a
     * field, set it to the empty string. Only callable by the list manager.
     * @param nonce The nonce corresponding to the list to update.
     * @param key The key to set.
     * @param value The value to set.
     */
    function setMetadataValue(uint256 nonce, string calldata key, bytes calldata value)
        external
        onlyListManager(nonce)
    {
        _setMetadataValue(nonce, key, value);
    }

    function _setMetadataValues(uint256 nonce, KeyValue[] calldata records) internal {
        uint256 length = records.length;
        for (uint256 i = 0; i < length;) {
            KeyValue calldata record = records[i];
            _setMetadataValue(nonce, record.key, record.value);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Sets an array of metadata records for a token ID. Each record is a
     * key/value pair. Only callable by the list manager.
     * @param nonce The nonce corresponding to the list to update.
     * @param records The records to set.
     */
    function setMetadataValues(uint256 nonce, KeyValue[] calldata records) external onlyListManager(nonce) {
        _setMetadataValues(nonce, records);
    }

    ///////////////////////////////////////////////////////////////////////////
    // Modifiers
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Ensures that the caller is the manager of the specified list.
     * @param nonce The unique identifier of the list.
     * @dev Used to restrict function access to the list's manager.
     */
    modifier onlyListManager(uint256 nonce) {
        bytes memory existing = values[nonce]["manager"];
        // if not set, claim for msg.sender
        if (existing.length != 20) {
            _claimListManager(nonce, msg.sender);
        } else {
            address existingManager = bytesToAddress(existing);
            if (existingManager == address(0)) {
                _claimListManager(nonce, msg.sender);
            } else {
                require(existingManager == msg.sender, "Not list manager");
            }
        }
        _;
    }

    ///////////////////////////////////////////////////////////////////////////
    // List Manager - Claim
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Allows an address to claim management of an unclaimed list nonce.
     * @param nonce The nonce that the sender wishes to claim.
     * @param manager The address to be set as the manager.
     * @dev This function establishes the first-come-first-serve basis for nonce claiming.
     */
    function _claimListManager(uint256 nonce, address manager) internal {
        bytes memory existing = values[nonce]["manager"];
        // require(existing.length != 20 || bytesToAddress(existing) == manager, "nonce already claimed");
        if (existing.length == 20) {
            address existingManager = bytesToAddress(existing);
            if (existingManager != manager) {
                revert NonceAlreadyClaimed(nonce, existingManager);
            }
        }
        _setMetadataValue(nonce, "manager", abi.encodePacked(manager));
    }

    /**
     * @notice Allows the sender to claim management of an unclaimed list nonce.
     * @param nonce The nonce that the sender wishes to claim.
     */
    function claimListManager(uint256 nonce) external {
        _claimListManager(nonce, msg.sender);
    }

    /**
     * @notice Allows the sender to transfer management of a list to a new address.
     * @param nonce The list's unique identifier.
     * @param manager The address to be set as the new manager.
     */
    function claimListManagerForAddress(uint256 nonce, address manager) external {
        _claimListManager(nonce, manager);
    }

    ///////////////////////////////////////////////////////////////////////////
    // List Manager - Read
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Retrieves the address of the manager for a specified list nonce.
     * @param nonce The list's unique identifier.
     * @return The address of the manager.
     */
    function getListManager(uint256 nonce) external view returns (address) {
        bytes memory existing = values[nonce]["manager"];
        return existing.length != 20 ? address(0) : bytesToAddress(existing);
    }

    ///////////////////////////////////////////////////////////////////////////
    // List Manager - Write
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Allows the current manager to transfer management of a list to a new address.
     * @param nonce The list's unique identifier.
     * @param manager The address to be set as the new manager.
     * @dev Only the current manager can transfer their management role.
     */
    function setListManager(uint256 nonce, address manager) external onlyListManager(nonce) {
        _setMetadataValue(nonce, "manager", abi.encodePacked(manager));
    }

    ///////////////////////////////////////////////////////////////////////////
    // List User - Read
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Retrieves the address of the list user for a specified list
     *         nonce.
     * @param nonce The list's unique identifier.
     * @return The address of the list user.
     */
    function getListUser(uint256 nonce) external view returns (address) {
        bytes memory existing = values[nonce]["user"];
        return existing.length != 20 ? address(0) : bytesToAddress(existing);
    }

    ///////////////////////////////////////////////////////////////////////////
    // List Manager - Write
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Allows the current manager to change the list user to a new
     *         address.
     * @param nonce The list's unique identifier.
     * @param user The address to be set as the new list user.
     * @dev Only the current manager can change the list user.
     */
    function setListUser(uint256 nonce, address user) external onlyListManager(nonce) {
        _setMetadataValue(nonce, "user", abi.encodePacked(user));
    }
}

/**
 * @title EFPListRecords
 * @notice Manages a dynamic list of records associated with EFP List NFTs.
 *         Provides functionalities for list managers to apply operations to their lists.
 */
abstract contract ListRecords is IEFPListRecords, ListMetadata {
    ///////////////////////////////////////////////////////////////////////////
    // Data Structures
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Stores a sequence of operations for each list identified by its nonce.
    /// @dev Each list can have multiple operations performed over time.
    mapping(uint256 => bytes[]) public listOps;

    ///////////////////////////////////////////////////////////////////////////
    // List Operation Functions -  Read
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Retrieves the number of operations performed on a list.
     * @param nonce The list's unique identifier.
     * @return The number of operations performed on the list.
     */
    function getListOpCount(uint256 nonce) external view returns (uint256) {
        return listOps[nonce].length;
    }

    /**
     * @notice Retrieves the operation at a specified index for a list.
     * @param nonce The list's unique identifier.
     * @param index The index of the operation to be retrieved.
     * @return The operation at the specified index.
     */
    function getListOp(uint256 nonce, uint256 index) external view returns (bytes memory) {
        return listOps[nonce][index];
    }

    /**
     * @notice Retrieves a range of operations for a list.
     * @param nonce The list's unique identifier.
     * @param start The starting index of the range.
     * @param end The ending index of the range.
     * @return The operations in the specified range.
     */
    function getListOpsInRange(uint256 nonce, uint256 start, uint256 end) external view returns (bytes[] memory) {
        if (start > end) {
            revert("Invalid range");
        }

        bytes[] memory ops = new bytes[](end - start);
        for (uint256 i = start; i < end;) {
            ops[i - start] = listOps[nonce][i];

            unchecked {
                ++i;
            }
        }
        return ops;
    }

    /**
     * @notice Retrieves all operations for a list.
     * @param nonce The list's unique identifier.
     * @return The operations performed on the list.
     */
    function getAllListOps(uint256 nonce) external view returns (bytes[] memory) {
        return listOps[nonce];
    }

    ///////////////////////////////////////////////////////////////////////////
    // List Operation Functions - Write
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Applies a single operation to the list.
     * @param nonce The list's unique identifier.
     * @param op The operation to be applied.
     */
    function _applyListOp(uint256 nonce, bytes calldata op) internal {
        listOps[nonce].push(op);
        emit ListOp(nonce, op);
    }

    /**
     * @notice Public wrapper for `_applyOp`, enabling list managers to apply a single operation.
     * @param nonce The list's unique identifier.
     * @param op The operation to be applied.
     */
    function applyListOp(uint256 nonce, bytes calldata op) public onlyListManager(nonce) {
        _applyListOp(nonce, op);
    }

    /**
     * @notice Allows list managers to apply multiple operations in a single transaction.
     * @param nonce The list's unique identifier.
     * @param ops An array of operations to be applied.
     */
    function _applyListOps(uint256 nonce, bytes[] calldata ops) internal {
        uint256 len = ops.length;
        for (uint256 i = 0; i < len;) {
            _applyListOp(nonce, ops[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Allows list managers to apply multiple operations in a single transaction.
     * @param nonce The list's unique identifier.
     * @param ops An array of operations to be applied.
     */
    function applyListOps(uint256 nonce, bytes[] calldata ops) public onlyListManager(nonce) {
        _applyListOps(nonce, ops);
    }

    /**
     * @notice Allows list managers to set metadata values and apply list ops
     *        in a single transaction.
     * @param nonce The list's unique identifier.
     * @param records An array of key-value pairs to set.
     * @param ops An array of operations to be applied.
     */
    function setMetadataValuesAndApplyListOps(uint256 nonce, KeyValue[] calldata records, bytes[] calldata ops)
        external
        onlyListManager(nonce)
    {
        _setMetadataValues(nonce, records);
        _applyListOps(nonce, ops);
    }
}

contract EFPListRecords is IEFPListRecords, ListRecords, ENSReverseClaimer {}
