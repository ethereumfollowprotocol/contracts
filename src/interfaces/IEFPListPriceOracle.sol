// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

/**
 * @title IEFPListPriceOracle
 */
interface IEFPListPriceOracle {
  function getPrice(uint256 tokenId, uint256 quantity) external view returns (uint256);
}
