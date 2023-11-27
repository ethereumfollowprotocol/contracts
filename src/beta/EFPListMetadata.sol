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

  /// @dev The key-value set for each token ID
  mapping(uint => mapping(string => bytes)) private values;

  /// @dev The EFP List Registry contract
  IERC721 public efpListRegistry;

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
  // Modifier
  /////////////////////////////////////////////////////////////////////////////

  modifier onlyTokenOwner(uint tokenId) {
    require(efpListRegistry.ownerOf(tokenId) == msg.sender, "not token owner");
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
  function getValue(uint tokenId, string calldata key) external view returns (bytes memory) {
    return values[tokenId][key];
  }

  /**
   * @dev Retrieves values for token ID and keys.
   * @param tokenId The token Id to query.
   * @param keys The keys to query.
   * @return The associated values.
   */
  function getValues(uint tokenId, string[] calldata keys) external view returns (bytes[] memory) {
    uint length = keys.length;
    bytes[] memory result = new bytes[](length);
    for (uint256 i = 0; i < length; ) {
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
  function _setValue(uint tokenId, string calldata key, bytes calldata value) internal {
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
  function setValue(uint tokenId, string calldata key, bytes calldata value) external onlyTokenOwner(tokenId) {
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
    uint tokenId,
    string calldata key,
    bytes calldata value,
    string calldata key2,
    bytes calldata value2
  ) external onlyTokenOwner(tokenId) {
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
  // ) external onlyTokenOwner(tokenId) {
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
  function setValues(uint tokenId, KeyValue[] calldata records) external onlyTokenOwner(tokenId) {
    uint length = records.length;
    for (uint256 i = 0; i < length; ) {
      KeyValue calldata record = records[i];
      _setValue(tokenId, record.key, record.value);
      unchecked {
        ++i;
      }
    }
  }
}