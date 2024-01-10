// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

/**
 * @title IEFPListMetadata
 */
interface IEFPListMetadata {
  event UpdateListMetadata(uint256 indexed slot, string key, bytes value);

  struct KeyValue {
    string key;
    bytes value;
  }

  function getMetadataValue(uint256 slot, string calldata key) external view returns (bytes memory);

  function getMetadataValues(uint256 slot, string[] calldata keys) external view returns (bytes[] memory);

  function setMetadataValue(uint256 slot, string calldata key, bytes calldata value) external;

  function setMetadataValues(uint256 slot, KeyValue[] calldata records) external;

  // List Manager Functions
  function claimListManager(uint256 slot) external;

  function claimListManagerForAddress(uint256 slot, address manager) external;

  function getListManager(uint256 slot) external view returns (address);

  function setListManager(uint256 slot, address manager) external;

  // List User Functions
  function getListUser(uint256 slot) external view returns (address);

  function setListUser(uint256 slot, address user) external;
}

/**
 * @title IEFPListRecords
 * @notice Interface for the ListRecords contract.
 */
interface IEFPListRecords is IEFPListMetadata {
  // Events
  event ListOp(uint256 indexed slot, bytes op);

  // List Operation Functions - Read
  function getListOpCount(uint256 slot) external view returns (uint256);

  function getListOp(uint256 slot, uint256 index) external view returns (bytes memory);

  function getListOpsInRange(uint256 slot, uint256 start, uint256 end) external view returns (bytes[] memory);

  function getAllListOps(uint256 slot) external view returns (bytes[] memory);

  // List Operation Functions - Write
  function applyListOp(uint256 slot, bytes calldata op) external;

  function applyListOps(uint256 slot, bytes[] calldata ops) external;

  function setMetadataValuesAndApplyListOps(uint256 slot, KeyValue[] calldata records, bytes[] calldata ops) external;
}
