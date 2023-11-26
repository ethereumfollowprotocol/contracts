// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "lib/ERC721A/contracts/ERC721A.sol";
import {IEFPListRegistry} from "./IEFPListRegistry.sol";
import {IEFPListPriceOracle} from "./IEFPListPriceOracle.sol";
import {ListStorageLocation} from "./ListStorageLocation.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title EFPListRegistry
 * @notice A registry connecting token IDs with data such as managers, users, and list locations.
 */
contract EFPListRegistry is IEFPListRegistry, ERC721A, Ownable {

    ///////////////////////////////////////////////////////////////////////////
    // Enums
    ///////////////////////////////////////////////////////////////////////////

    enum MintState { Disabled, OwnerOnly, PublicMint, PublicBatch }

    ///////////////////////////////////////////////////////////////////////////
    // Events
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Emitted when the mint batch size is changed.
    event MaxMintBatchSizeChange(uint maxMintBatchSize);

    /// @notice Emitted when the mint state is changed.
    event MintStateChange(MintState mintState);

    /// @notice Emitted when the price oracle is changed.
    event PriceOracleChange(address priceOracle);

    ///////////////////////////////////////////////////////////////////////////
    // Data Structures
    ///////////////////////////////////////////////////////////////////////////

    // mapping(uint => ListStorageLocation) private tokenIdToListStorageLocation;

    // mapping(uint => address) private tokenIdToListUser;

    MintState private mintState = MintState.Disabled;

    uint private maxMintBatchSize = 10000;

    IEFPListPriceOracle private priceOracle;

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
    modifier onlyTokenOwner(uint tokenId) {
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
    function getMaxMintBatchSize() external view returns (uint) {
        return maxMintBatchSize;
    }

    /// @notice Sets the max mint batch size.
    /// @param _maxMintBatchSize The new max mint batch size.
    function setMaxMintBatchSize(uint _maxMintBatchSize) external onlyOwner {
        maxMintBatchSize = _maxMintBatchSize;
        emit MaxMintBatchSizeChange(_maxMintBatchSize);
    }

    /// @notice Mints a new token.
    function mint() public payable mintAllowed {
        uint price = (address(priceOracle) != address(0)) ? priceOracle.getPrice(totalSupply(), 1) : 0;
        require(msg.value >= price, "insufficient funds");

        _mint(msg.sender, 1);
    }

    /**
     * @notice Mints a new token to the given address.
     * @param to The address to mint the token to.
    */
    function mintTo(address to) public payable mintAllowed {
        uint price = (address(priceOracle) != address(0)) ? priceOracle.getPrice(totalSupply(), 1) : 0;
        require(msg.value >= price, "insufficient funds");

        _mint(to, 1);
    }

    /// @notice Mints a batch of new tokens.
    /// @param quantity The number of tokens to mint.
    function mintBatch(uint quantity) public payable mintBatchAllowed {
        require(quantity <= maxMintBatchSize, "batch size too big");

        uint price = (address(priceOracle) != address(0)) ? priceOracle.getPrice(totalSupply(), quantity) : 0;
        require(msg.value >= price, "insufficient funds");

        _mint(msg.sender, quantity);
    }

    /// @notice Mints a batch of new tokens.
    /// @param to The address to mint the tokens to.
    /// @param quantity The number of tokens to mint.
    function mintBatchTo(address to, uint quantity) public payable mintBatchAllowed {
        require(quantity <= maxMintBatchSize, "batch size too big");

        uint price = (address(priceOracle) != address(0)) ? priceOracle.getPrice(totalSupply(), quantity) : 0;
        require(msg.value >= price, "insufficient funds");

        _mint(to, quantity);
    }

    // ///////////////////////////////////////////////////////////////////////////
    // // List Location
    // ///////////////////////////////////////////////////////////////////////////

    // /**
    //  * @notice Fetches the list location associated with a specific token.
    //  * @param tokenId The ID of the token.
    //  * @return The list location.
    //  */
    // function getListStorageLocation(uint tokenId) external view returns (ListStorageLocation memory) {
    //     return tokenIdToListStorageLocation[tokenId];
    // }

    // /**
    //  * @notice Associates a token with a list storage location.
    //  * @param tokenId The ID of the token.
    //  * @param listStorageLocation The list storage location to be associated with the token.
    //  */
    // function setListStorageLocation(uint tokenId, ListStorageLocation calldata listStorageLocation) external onlyTokenOwner(tokenId) {
    //     tokenIdToListStorageLocation[tokenId] = listStorageLocation;
    //     emit ListStorageLocationChange(tokenId, listStorageLocation);
    // }

    // ///////////////////////////////////////////////////////////////////////////
    // // User
    // ///////////////////////////////////////////////////////////////////////////

    // /**
    //  * @notice Fetches the user associated with a specific token.
    //  * @param tokenId The ID of the token.
    //  * @return The Ethereum address of the user.
    //  */
    // function getUser(uint tokenId) external view returns (address) {
    //     address user = tokenIdToListUser[tokenId];

    //     // distinguish from 0x0000...0000 address
    //     return (user != address(0)) ? user : ownerOf(tokenId);
    // }

    // /**
    //  * @notice Sets the user for a specific token.
    //  * @param tokenId The ID of the token.
    //  * @param userAddress The Ethereum address of the user.
    //  */
    // function setUser(uint tokenId, address userAddress) external onlyTokenOwner(tokenId) {
    //     require(ownerOf(tokenId) == msg.sender, "EFP: caller is not the manager");
    //     tokenIdToListUser[tokenId] = userAddress;
    //     emit ListUserChange(tokenId, userAddress);
    // }
}
