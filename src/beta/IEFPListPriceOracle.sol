// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title IEFPListPriceOracle
 */
interface IEFPListPriceOracle {

    function getPrice(uint tokenId, uint quantity) external view returns (uint);
}