// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

/**
 * @title IEFPAccountMetadata
 */
interface IEFPAccountMetadata {
  function addProxy(address proxy) external;

  function removeProxy(address proxy) external;

  function isProxy(address proxy) external view returns (bool);

  event UpdateAccountMetadata(address indexed addr, string key, bytes value);

  /**
   * @title Key-value Record
   * @notice A key-value string pair.
   */
  struct KeyValue {
    string key;
    bytes value;
  }

  function getValue(address addr, string calldata key) external view returns (bytes memory);

  function setValue(string calldata key, bytes calldata value) external;

  function setValueForAddress(address addr, string calldata key, bytes calldata value) external;

  function setValues(KeyValue[] calldata records) external;

  function setValuesForAddress(address addr, KeyValue[] calldata records) external;
}
