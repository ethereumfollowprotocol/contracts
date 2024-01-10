//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Ownable} from 'lib/openzeppelin-contracts/contracts/access/Ownable.sol';

interface ENS {
  /**
   * @dev Returns the address that owns the specified node.
   * @param node The specified node.
   * @return address of the owner.
   */
  function owner(bytes32 node) external view returns (address);
}

interface IReverseRegistrar {
  /**
   * @dev Transfers ownership of the reverse ENS record associated with the
   *      calling account.
   * @param owner The address to set as the owner of the reverse record in ENS.
   * @return The ENS node hash of the reverse record.
   */
  function claim(address owner) external returns (bytes32);

  /**
   * @dev Sets the `name()` record for the reverse ENS record associated with
   * the calling account. First updates the resolver to the default reverse
   * resolver if necessary.
   * @param name The name to set for this address.
   * @return The ENS node hash of the reverse record.
   */
  function setName(string memory name) external returns (bytes32);
}

/**
 * @title ENSReverseClaimer
 * @dev This contract is used to claim reverse ENS records.
 */
abstract contract ENSReverseClaimer is Ownable {
  /// @dev The namehash of 'addr.reverse', the domain at which reverse records
  ///      are stored in ENS.
  bytes32 constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

  /**
   * @dev Transfers ownership of the reverse ENS record associated with the
   *      contract.
   * @param ens The ENS registry.
   * @param claimant The address to set as the owner of the reverse record in
   *                 ENS.
   * @return The ENS node hash of the reverse record.
   */
  function claimReverseENS(ENS ens, address claimant) external onlyOwner returns (bytes32) {
    return IReverseRegistrar(ens.owner(ADDR_REVERSE_NODE)).claim(claimant);
  }

  /**
   * @dev Sets the reverse ENS record associated with the contract.
   * @param ens The ENS registry.
   * @param name The name to set as the reverse record in ENS.
   * @return The ENS node hash of the reverse record.
   */
  function setReverseENS(ENS ens, string calldata name) external onlyOwner returns (bytes32) {
    return IReverseRegistrar(ens.owner(ADDR_REVERSE_NODE)).setName(name);
  }
}
