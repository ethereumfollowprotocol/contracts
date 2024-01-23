// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

interface ITokenURIProvider {
  function tokenURI(uint256 tokenId) external view returns (string memory);
}
