// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IEFPListMetadata} from "./IEFPListMetadata.sol";

/**
 * @title EFPListMetadata
 *
 * @notice This contract stores records as key/value pairs, by 32-byte
 * EFP List Token ID.
 */
contract EFPListMetadata is IEFPListMetadata, Ownable {
    event ProxyAdded(address proxy);

    event ProxyRemoved(address proxy);

    /// @dev The EFP List Registry contract
    IERC721 public efpListRegistry;

    /// @dev The key-value set for each token ID
    mapping(uint256 => mapping(string => bytes)) private values;

    mapping(address => bool) private proxies;

    /**
     * @dev Get the address of the EFP List Registry contract.
     * @return The address of the EFP List Registry contract.
     */
    function getEFPListRegistry() external view returns (address) {
        return address(efpListRegistry);
    }

    /**
     * @dev Set the address of the EFP List Registry contract.
     * @param efpListRegistry_ The address of the EFP List Registry contract.
     */
    function setEFPListRegistry(address efpListRegistry_) public onlyOwner {
        efpListRegistry = IERC721(efpListRegistry_);
    }

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

    modifier onlyTokenOwnerOrProxy(uint256 tokenId) {
        require(efpListRegistry.ownerOf(tokenId) == msg.sender || proxies[msg.sender], "not token owner");
        _;
    }

    /////////////////////////////////////////////////////////////////////////////
    // Getters
    /////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Retrieves value for token ID and key.
     * @param tokenId The token Id to query.
     * @param key The key to query.
     * @return The associated value.
     */
    function getValue(uint256 tokenId, string calldata key) external view returns (bytes memory) {
        return values[tokenId][key];
    }

    /**
     * @dev Retrieves values for token ID and keys.
     * @param tokenId The token Id to query.
     * @param keys The keys to query.
     * @return The associated values.
     */
    function getValues(uint256 tokenId, string[] calldata keys) external view returns (bytes[] memory) {
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
     * @dev Sets records for token ID with the unique key key to value,
     * overwriting anything previously stored for token ID and key. To clear a
     * field, set it to the empty string.
     * @param tokenId The token ID to update.
     * @param key The key to set.
     * @param value The value to set.
     */
    function _setValue(uint256 tokenId, string calldata key, bytes calldata value) internal {
        values[tokenId][key] = value;
        emit ValueSet(tokenId, key, value);
    }

    /**
     * @dev Sets records for token ID with the unique key key to value,
     * overwriting anything previously stored for token ID and key. To clear a
     * field, set it to the empty string.
     * Only callable by the token owner.
     * @param tokenId The token ID to update.
     * @param key The key to set.
     * @param value The value to set.
     */
    function setValue(uint256 tokenId, string calldata key, bytes calldata value)
        external
        onlyTokenOwnerOrProxy(tokenId)
    {
        _setValue(tokenId, key, value);
    }

    /**
     * @dev Sets records for token ID with the unique key key to value,
     * overwriting anything previously stored for token ID and key. To clear a
     * field, set it to the empty string.
     * Only callable by the token owner.
     * @param tokenId The token ID to update.
     * @param key The key to set.
     * @param value The value to set.
     * @param key2 The second key to set.
     * @param value2 The second value to set.
     */
    function setValue2(
        uint256 tokenId,
        string calldata key,
        bytes calldata value,
        string calldata key2,
        bytes calldata value2
    ) external onlyTokenOwnerOrProxy(tokenId) {
        _setValue(tokenId, key, value);
        _setValue(tokenId, key2, value2);
    }

    // /**
    //  * @dev Sets records for token ID with the unique key key to value,
    //  * overwriting anything previously stored for token ID and key. To clear a
    //  * field, set it to the empty string.
    //  * Only callable by the token owner.
    //  * @param tokenId The token ID to update.
    //  * @param key The key to set.
    //  * @param value The value to set.
    //  * @param key2 The second key to set.
    //  * @param value2 The second value to set.
    //  * @param key3 The third key to set.
    //  * @param value3 The third value to set.
    //  */
    // function setValue3(
    //   uint tokenId,
    //   string calldata key,
    //   bytes calldata value,
    //   string calldata key2,
    //   bytes calldata value2,
    //   string calldata key3,
    //   bytes calldata value3
    // ) external onlyTokenOwnerOrProxy(tokenId) {
    //   _setValue(tokenId, key, value);
    //   _setValue(tokenId, key2, value2);
    //   _setValue(tokenId, key3, value3);
    // }

    /**
     * @dev Sets an array of records for a token ID. Each record is a key/value pair.
     * Only callable by the token owner.
     * @param tokenId The token ID to update.
     * @param records The records to set.
     */
    function setValues(uint256 tokenId, KeyValue[] calldata records) external onlyTokenOwnerOrProxy(tokenId) {
        uint256 length = records.length;
        for (uint256 i = 0; i < length;) {
            KeyValue calldata record = records[i];
            _setValue(tokenId, record.key, record.value);
            unchecked {
                ++i;
            }
        }
    }
}
