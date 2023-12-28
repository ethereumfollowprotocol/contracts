// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC721A} from "lib/ERC721A/contracts/ERC721A.sol";
import {IEFPListRegistry} from "./interfaces/IEFPListRegistry.sol";
import {IEFPListPriceOracle} from "./interfaces/IEFPListPriceOracle.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title EFPListRegistry
 * @notice A registry connecting token IDs with data such as managers, users, and list locations.
 */
contract EFPListRegistry is IEFPListRegistry, ERC721A, Ownable {
    ///////////////////////////////////////////////////////////////////////////
    // Events
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Emitted when the mint batch size is changed.
    event MaxMintBatchSizeChange(uint256 maxMintBatchSize);

    /// @notice Emitted when the mint state is changed.
    event MintStateChange(MintState mintState);

    /// @notice Emitted when the price oracle is changed.
    event PriceOracleChange(address priceOracle);

    ///////////////////////////////////////////////////////////////////////////
    // Data Structures
    ///////////////////////////////////////////////////////////////////////////

    /// @notice The state of minting.
    MintState private mintState = MintState.Disabled;

    /// @notice The maximum number of tokens that can be minted in a single batch.
    uint256 private maxMintBatchSize = 10000;

    /// @notice The price oracle. If set, the price oracle is used to determine
    /// the price of minting.
    IEFPListPriceOracle private priceOracle;

    /// @notice The list storage location associated with a token.
    mapping(uint256 => bytes) private tokenIdToListStorageLocation;

    ///////////////////////////////////////////////////////////////////////////
    // Constructor
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Constructs a new ListRegistry and sets its name and symbol.
    constructor() ERC721A("EFP", "EFP") {}

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
    function setPriceOracle(address priceOracle_) external onlyOwner {
        priceOracle = IEFPListPriceOracle(priceOracle_);
        emit PriceOracleChange(priceOracle_);
    }

    ///////////////////////////////////////////////////////////////////////////
    // Modifiers
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Restrict access to the owner of a specific token.
    modifier onlyTokenOwner(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender, "EFP: caller is not the owner");
        _;
    }

    /// @notice Restrict mint if minting is disabled OR restricted to owner && caller is not owner.
    modifier mintAllowed() {
        require(mintState != MintState.Disabled, "EFP: minting is disabled");
        require(mintState != MintState.OwnerOnly || msg.sender == owner(), "EFP: minting is restricted to owner");
        // else PublicMint allowed
        // else PublicBatch allowed
        _;
    }

    /// @notice Restrict mint if minting is disabled OR restricted to owner && caller is not owner OR restricted to public single
    modifier mintBatchAllowed() {
        require(mintState != MintState.Disabled, "EFP: minting is disabled");
        require(mintState != MintState.OwnerOnly || msg.sender == owner(), "EFP: minting is restricted to owner");
        require(mintState != MintState.PublicMint || msg.sender == owner(), "EFP: batch minting is restricted to owner");
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
        emit ListStorageLocationChange(tokenId, listStorageLocation);
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
    function setMintState(MintState _mintState) external onlyOwner {
        mintState = _mintState;
        emit MintStateChange(_mintState);
    }

    /// @notice Fetches the max mint batch size.
    function getMaxMintBatchSize() external view returns (uint256) {
        return maxMintBatchSize;
    }

    /// @notice Sets the max mint batch size.
    /// @param _maxMintBatchSize The new max mint batch size.
    function setMaxMintBatchSize(uint256 _maxMintBatchSize) external onlyOwner {
        maxMintBatchSize = _maxMintBatchSize;
        emit MaxMintBatchSizeChange(_maxMintBatchSize);
    }

    /**
     * @notice Mints a new token.
     * @param listStorageLocation The list storage location to be associated with the token.
     */
    function mint(bytes calldata listStorageLocation) public payable mintAllowed {
        uint256 tokenId = totalSupply();
        uint256 price = (address(priceOracle) != address(0)) ? priceOracle.getPrice(tokenId, 1) : 0;
        require(msg.value >= price, "insufficient funds");

        _safeMint(msg.sender, 1);
        _setListStorageLocation(tokenId, listStorageLocation);
    }

    /**
     * @notice Mints a new token to the given address.
     * @param to The address to mint the token to.
     * @param listStorageLocation The list storage location to be associated with the token.
     */
    function mintTo(address to, bytes calldata listStorageLocation) public payable mintAllowed {
        uint256 tokenId = totalSupply();
        uint256 price = (address(priceOracle) != address(0)) ? priceOracle.getPrice(tokenId, 1) : 0;
        require(msg.value >= price, "insufficient funds");

        _safeMint(to, 1);
        _setListStorageLocation(tokenId, listStorageLocation);
    }

    /// @notice Mints a batch of new tokens.
    /// @param quantity The number of tokens to mint.
    function mintBatch(uint256 quantity) public payable mintBatchAllowed {
        require(quantity <= maxMintBatchSize, "batch size too big");

        uint256 price = (address(priceOracle) != address(0)) ? priceOracle.getPrice(totalSupply(), quantity) : 0;
        require(msg.value >= price, "insufficient funds");

        _safeMint(msg.sender, quantity);
        // leave tokenIdToListStorageLocation unset for these tokens
    }

    /// @notice Mints a batch of new tokens.
    /// @param to The address to mint the tokens to.
    /// @param quantity The number of tokens to mint.
    function mintBatchTo(address to, uint256 quantity) public payable mintBatchAllowed {
        require(quantity <= maxMintBatchSize, "batch size too big");

        uint256 price = (address(priceOracle) != address(0)) ? priceOracle.getPrice(totalSupply(), quantity) : 0;
        require(msg.value >= price, "insufficient funds");

        _safeMint(to, quantity);
        // leave tokenIdToListStorageLocation unset for these tokens
    }
}
