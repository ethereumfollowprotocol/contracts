// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {ERC721A} from 'lib/ERC721A/contracts/ERC721A.sol';
import {ERC721AQueryable} from 'lib/ERC721A/contracts/extensions/ERC721AQueryable.sol';
import {IERC721A} from 'lib/ERC721A/contracts/interfaces/IERC721A.sol';
import {Ownable} from 'lib/openzeppelin-contracts/contracts/access/Ownable.sol';
import {Pausable} from 'lib/openzeppelin-contracts/contracts/security/Pausable.sol';
import {IEFPListRegistry} from './interfaces/IEFPListRegistry.sol';
import {IEFPListNFTPriceOracle} from './interfaces/IEFPListNFTPriceOracle.sol';
import {ITokenURIProvider} from './interfaces/ITokenURIProvider.sol';
import {ENSReverseClaimer} from './lib/ENSReverseClaimer.sol';

/**
 * @title EFPListRegistry
 * @author Cory Gabrielsen (cory.eth)
 *
 * @notice The EPF List Registry is an ERC721A contract representing ownership
 * of an EFP List. EFP List NFT owners may set the List Storage Location
 * associated with their EFP List by calling setListStorageLocation.
 */
contract EFPListRegistry is IEFPListRegistry, ERC721A, ERC721AQueryable, ENSReverseClaimer, Pausable {
  ///////////////////////////////////////////////////////////////////////////
  // Events
  ///////////////////////////////////////////////////////////////////////////

  /// @notice Emitted when the mint batch size is changed.
  event MaxMintBatchSizeChange(uint256 maxMintBatchSize);

  /// @notice Emitted when the mint state is changed.
  event MintStateChange(MintState mintState);

  /// @notice Emitted when the price oracle is changed.
  event PriceOracleChange(address priceOracle);

  /// @notice Emitted when the token URI provider is changed.
  event TokenURIProviderChange(address tokenURIProvider);

  ///////////////////////////////////////////////////////////////////////////
  // Data Structures
  ///////////////////////////////////////////////////////////////////////////

  /// @notice The state of minting.
  MintState private mintState = MintState.Disabled;

  /// @notice The maximum number of tokens that can be minted in a single batch.
  uint256 private maxMintBatchSize = 10000;

  /// @notice The price oracle. If set, the price oracle is used to determine
  /// the price of minting.
  IEFPListNFTPriceOracle private priceOracle;

  /// @notice The token URI provider.
  ITokenURIProvider public tokenURIProvider;

  /// @notice The list storage location associated with a token.
  mapping(uint256 => bytes) private tokenIdToListStorageLocation;

  ///////////////////////////////////////////////////////////////////////////
  // Constructor
  ///////////////////////////////////////////////////////////////////////////

  /// @notice Constructs a new ListRegistry and sets its name and symbol.
  constructor() ERC721A('EFP', 'EFP') {}

  /////////////////////////////////////////////////////////////////////////////
  // Pausable
  /////////////////////////////////////////////////////////////////////////////

  /**
   * @dev Pauses the contract. Can only be called by the contract owner.
   */
  function pause() public onlyOwner {
    _pause();
  }

  /**
   * @dev Unpauses the contract. Can only be called by the contract owner.
   */
  function unpause() public onlyOwner {
    _unpause();
  }

  ///////////////////////////////////////////////////////////////////////////
  // token uri provider getter/setter
  ///////////////////////////////////////////////////////////////////////////

  /**
   * @notice Sets the token URI provider.
   * @param tokenURIProvider_ The new token URI provider.
   */
  function setTokenURIProvider(address tokenURIProvider_) external onlyOwner {
    tokenURIProvider = ITokenURIProvider(tokenURIProvider_);
    emit TokenURIProviderChange(tokenURIProvider_);
  }

  /**
   * @dev Overrides the tokenURI function to delegate the call to the
   * TokenURIProvider contract. This allows the tokenURI logic to be
   * upgradeable.
   * @param tokenId The token ID for which the URI is requested.
   * @return A string representing the token URI.
   */
  function tokenURI(uint256 tokenId) public view override(IERC721A, ERC721A) returns (string memory) {
    require(address(tokenURIProvider) != address(0), 'TokenURI provider is not set');
    return tokenURIProvider.tokenURI(tokenId);
  }

  ///////////////////////////////////////////////////////////////////////////
  // price oracle getter/setter
  ///////////////////////////////////////////////////////////////////////////

  /// @notice Fetches the price oracle.
  function getPriceOracle() external view returns (address) {
    return address(priceOracle);
  }

  /**
   * @notice Sets the price oracle.
   * @param priceOracle_ The new price oracle.
   */
  function setPriceOracle(address priceOracle_) external whenNotPaused onlyOwner {
    priceOracle = IEFPListNFTPriceOracle(priceOracle_);
    emit PriceOracleChange(priceOracle_);
  }

  /**
   * @notice Fetches the price of minting a token.
   */
  function _getPrice(uint256 quantity) internal view returns (uint256) {
    return (address(priceOracle) != address(0))
      ? quantity == 1 ? priceOracle.getPrice() : priceOracle.getBatchPrice(quantity)
      : 0;
  }

  /**
   * @notice Withdraws Ether from the contract.
   *
   * @param recipient The address to send the Ether to.
   * @param amount The amount of Ether to send.
   * @return Whether the transfer succeeded.
   */
  function withdraw(address payable recipient, uint256 amount) public returns (bool) {
    require(amount <= address(this).balance, 'Insufficient balance');
    (bool sent,) = recipient.call{value: amount}('');
    require(sent, 'Failed to send Ether');
    return sent;
  }

  ///////////////////////////////////////////////////////////////////////////
  // Modifiers
  ///////////////////////////////////////////////////////////////////////////

  /// @notice Restrict access to the owner of a specific token.
  modifier onlyTokenOwner(uint256 tokenId) {
    require(ownerOf(tokenId) == msg.sender, 'EFP: caller is not the owner');
    _;
  }

  /// @notice Restrict mint if minting is disabled OR restricted to owner && caller is not owner.
  modifier mintAllowed() {
    require(mintState != MintState.Disabled, 'EFP: minting is disabled');
    require(mintState != MintState.OwnerOnly || msg.sender == owner(), 'EFP: minting is restricted to owner');
    // else PublicMint allowed
    // else PublicBatch allowed
    _;
  }

  /// @notice Restrict mint if minting is disabled OR restricted to owner && caller is not owner OR restricted to public single
  modifier mintBatchAllowed() {
    require(mintState != MintState.Disabled, 'EFP: minting is disabled');
    require(mintState != MintState.OwnerOnly || msg.sender == owner(), 'EFP: minting is restricted to owner');
    require(mintState != MintState.PublicMint || msg.sender == owner(), 'EFP: batch minting is restricted to owner');
    // else PublicBatch allowed
    _;
  }

  ///////////////////////////////////////////////////////////////////////////
  // ListStorageLocation
  ///////////////////////////////////////////////////////////////////////////

  /**
   * @notice Fetches the list location associated with a specific token.
   * @param tokenId The ID of the token.
   * @return The list location.
   */
  function getListStorageLocation(uint256 tokenId) external view override returns (bytes memory) {
    return tokenIdToListStorageLocation[tokenId];
  }

  /**
   * @notice Associates a token with a list storage location.
   * @param tokenId The ID of the token.
   * @param listStorageLocation The list storage location to be associated with the token.
   */
  function setListStorageLocation(uint256 tokenId, bytes calldata listStorageLocation)
    external
    override
    whenNotPaused
    onlyTokenOwner(tokenId)
  {
    _setListStorageLocation(tokenId, listStorageLocation);
  }

  /**
   * @notice Associates a token with a list storage location.
   * @param tokenId The ID of the token.
   * @param listStorageLocation The list storage location to be associated with the token.
   */
  function _setListStorageLocation(uint256 tokenId, bytes calldata listStorageLocation) internal {
    tokenIdToListStorageLocation[tokenId] = listStorageLocation;
    emit UpdateListStorageLocation(tokenId, listStorageLocation);
  }

  ///////////////////////////////////////////////////////////////////////////
  // Mint
  ///////////////////////////////////////////////////////////////////////////

  /// @notice Fetches the mint state.
  function getMintState() external view returns (MintState) {
    return mintState;
  }

  /// @notice Sets the mint state.
  /// @param _mintState The new mint state.
  function setMintState(MintState _mintState) external whenNotPaused onlyOwner {
    mintState = _mintState;
    emit MintStateChange(_mintState);
  }

  /// @notice Fetches the max mint batch size.
  function getMaxMintBatchSize() external view returns (uint256) {
    return maxMintBatchSize;
  }

  /// @notice Sets the max mint batch size.
  /// @param _maxMintBatchSize The new max mint batch size.
  function setMaxMintBatchSize(uint256 _maxMintBatchSize) external whenNotPaused onlyOwner {
    maxMintBatchSize = _maxMintBatchSize;
    emit MaxMintBatchSizeChange(_maxMintBatchSize);
  }

  /**
   * @notice Mints a new token.
   * @param listStorageLocation The list storage location to be associated with the token.
   */
  function mint(bytes calldata listStorageLocation) external payable whenNotPaused mintAllowed {
    uint256 tokenId = totalSupply();
    uint256 price = _getPrice(1);
    require(msg.value >= price, 'insufficient funds');

    _safeMint(msg.sender, 1);
    _setListStorageLocation(tokenId, listStorageLocation);
  }

  /**
   * @notice Mints a new token to the given address.
   * @param recipient The address to mint the token to.
   * @param listStorageLocation The list storage location to be associated with the token.
   */
  function mintTo(address recipient, bytes calldata listStorageLocation) external payable whenNotPaused mintAllowed {
    uint256 tokenId = totalSupply();
    uint256 price = _getPrice(1);
    require(msg.value >= price, 'insufficient funds');

    _safeMint(recipient, 1);
    _setListStorageLocation(tokenId, listStorageLocation);
  }

  /// @notice Mints a batch of new tokens.
  /// @param quantity The number of tokens to mint.
  function mintBatch(uint256 quantity) external payable whenNotPaused mintBatchAllowed {
    require(quantity <= maxMintBatchSize, 'batch size too big');

    uint256 price = _getPrice(quantity);
    require(msg.value >= price, 'insufficient funds');

    _safeMint(msg.sender, quantity);
    // leave tokenIdToListStorageLocation unset for these tokens
  }

  /// @notice Mints a batch of new tokens.
  /// @param recipient The address to mint the tokens to.
  /// @param quantity The number of tokens to mint.
  function mintBatchTo(address recipient, uint256 quantity) external payable whenNotPaused mintBatchAllowed {
    require(quantity <= maxMintBatchSize, 'batch size too big');

    uint256 price = _getPrice(quantity);
    require(msg.value >= price, 'insufficient funds');

    _safeMint(recipient, quantity);
    // leave tokenIdToListStorageLocation unset for these tokens
  }
}
