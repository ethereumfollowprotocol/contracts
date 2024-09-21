// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Ownable} from 'lib/openzeppelin-contracts/contracts/access/Ownable.sol';
import {Strings} from 'lib/openzeppelin-contracts/contracts/utils/Strings.sol';
import {ITokenURIProvider} from './interfaces/ITokenURIProvider.sol';

/**
 * @title TokenURIProvider
 * @author throw; (0xthrpw.eth)
 * @custom:benediction DEVS BENEDICAT ET PROTEGAT CONTRACTVS MEAM
 *
 * @notice This contract allows the owner to set a base URI for token URIs and
 * returns the token URI for a given token ID.  Separating this functionality allows
 * the logic for generating token URIs to be upgradable.
 */
contract TokenURIProvider is ITokenURIProvider, Ownable {
  string private _baseURI;

  using Strings for uint256;

  /**
   * @dev Constructor
   * @param baseURI The base URI for token URIs
   */
  constructor(string memory baseURI) {
    _baseURI = baseURI;
  }

  /**
   * @dev Returns the token URI for a given token ID
   * @param tokenId The token ID
   * @return The token URI
   */
  function tokenURI(uint256 tokenId) external view override returns (string memory) {
    return string(abi.encodePacked(_baseURI, tokenId.toString()));
  }

  /**
   * @dev Sets the base URI for token URIs
   * @param baseURI The new base URI
   */
  function setBaseURI(string memory baseURI) external onlyOwner {
    _baseURI = baseURI;
  }
}
