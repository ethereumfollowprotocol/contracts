// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

/**
 * @title IEFPListNFTPriceOracle
 */
interface IEFPListNFTPriceOracle {
  function getPrice() external view returns (uint256);

  function getBatchPrice(uint256 quantity) external view returns (uint256);
}
