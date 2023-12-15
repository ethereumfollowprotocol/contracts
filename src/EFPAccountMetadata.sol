// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IEFPAccountMetadata} from "./interfaces/IEFPAccountMetadata.sol";

/**
 * @title EFPListMetadata
 *
 * @notice This contract stores records as key/value pairs, by 32-byte
 * EFP List Token ID.
 */
contract EFPAccountMetadata is IEFPAccountMetadata, Ownable {
    event ProxyAdded(address proxy);

    event ProxyRemoved(address proxy);

    /// @dev The key-value set for each address
    mapping(address => mapping(string => bytes)) private values;

    mapping(address => bool) private proxies;

    /////////////////////////////////////////////////////////////////////////////
    // add/remove proxy
    /////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Add proxy address.
     * @param proxy The proxy address.
     */
    function addProxy(address proxy) external onlyOwner {
        proxies[proxy] = true;
        emit ProxyAdded(proxy);
    }

    /**
     * @dev Remove proxy address.
     * @param proxy The proxy address.
     */
    function removeProxy(address proxy) external onlyOwner {
        proxies[proxy] = false;
        emit ProxyRemoved(proxy);
    }

    /**
     * @dev Check if the address is a proxy.
     * @param proxy The address to check.
     * @return True if the address is a proxy, false otherwise.
     */
    function isProxy(address proxy) external view returns (bool) {
        return proxies[proxy];
    }

    /////////////////////////////////////////////////////////////////////////////
    // Modifier
    /////////////////////////////////////////////////////////////////////////////

    modifier onlyCallerOrProxy(address addr) {
        require(addr == msg.sender || proxies[msg.sender], "not allowed");
        _;
    }

    /////////////////////////////////////////////////////////////////////////////
    // Getters
    /////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Retrieves value for address and key.
     * @param addr The address to query.
     * @param key The key to query.
     * @return The associated value.
     */
    function getValue(address addr, string calldata key) external view returns (bytes memory) {
        return values[addr][key];
    }

    /**
     * @dev Retrieves values for address and keys.
     * @param addr The address to query.
     * @param keys The keys to query.
     * @return The associated values.
     */
    function getValues(address addr, string[] calldata keys) external view returns (bytes[] memory) {
        uint256 length = keys.length;
        bytes[] memory result = new bytes[](length);
        for (uint256 i = 0; i < length; ) {
            string calldata key = keys[i];
            result[i] = values[addr][key];
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
     * @dev Sets records for address with the unique key key to value,
     * overwriting anything previously stored for address and key. To clear a
     * field, set it to the empty string.
     * @param addr The address to update.
     * @param key The key to set.
     * @param value The value to set.
     */
    function _setValue(address addr, string calldata key, bytes calldata value) internal {
        values[addr][key] = value;
        emit NewAccountMetadataValue(addr, key, value);
    }

    /**
     * @dev Sets records for caller address with the unique key key to value,
     * overwriting anything previously stored for address and key. To clear a
     * field, set it to the empty string.
     * Only callable by the token owner.
     * @param key The key to set.
     * @param value The value to set.
     */
    function setValue(string calldata key, bytes calldata value) external {
        _setValue(msg.sender, key, value);
    }

    /**
     * @dev Sets records for address with the unique key key to value,
     * overwriting anything previously stored for address and key. To clear a
     * field, set it to the empty string.
     * Only callable by the token owner.
     * @param addr The address to update.
     * @param key The key to set.
     * @param value The value to set.
     */
    function setValueForAddress(
        address addr,
        string calldata key,
        bytes calldata value
    ) external onlyCallerOrProxy(addr) {
        _setValue(addr, key, value);
    }

    /**
     * @dev Sets an array of records for the caller address. Each record is a key/value pair.
     * Only callable by the token owner.
     * @param records The records to set.
     */
    function setValues(KeyValue[] calldata records) external {
        uint256 length = records.length;
        for (uint256 i = 0; i < length; ) {
            KeyValue calldata record = records[i];
            _setValue(msg.sender, record.key, record.value);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Sets an array of records for a address. Each record is a key/value pair.
     * Only callable by the token owner.
     * @param addr The address to update.
     * @param records The records to set.
     */
    function setValuesForAddress(address addr, KeyValue[] calldata records) external onlyCallerOrProxy(addr) {
        uint256 length = records.length;
        for (uint256 i = 0; i < length; ) {
            KeyValue calldata record = records[i];
            _setValue(addr, record.key, record.value);
            unchecked {
                ++i;
            }
        }
    }
}
