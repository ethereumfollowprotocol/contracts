// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title EFPListRegistry
 * @notice A registry connecting token IDs with data such as managers, users, and list locations.
 */
interface IEFPListRegistry {
    ///////////////////////////////////////////////////////////////////////////
    // Enums
    ///////////////////////////////////////////////////////////////////////////

    enum MintState {
        Disabled,
        OwnerOnly,
        PublicMint,
        PublicBatch
    }

    ///////////////////////////////////////////////////////////////////////////
    // Events
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Emitted when a list storage location is set
    event ListStorageLocationChange(uint256 indexed tokenId, bytes listStorageLocation);

    ///////////////////////////////////////////////////////////////////////////
    // ListStorageLocation
    ///////////////////////////////////////////////////////////////////////////

    function getListStorageLocation(uint256 tokenId) external view returns (bytes memory);

    function setListStorageLocation(uint256 tokenId, bytes calldata listStorageLocation) external;

    ///////////////////////////////////////////////////////////////////////////
    // Mint
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Fetches the mint state.
    function getMintState() external view returns (MintState);

    /// @notice Sets the mint state.
    /// @param _mintState The new mint state.
    function setMintState(MintState _mintState) external;

    /// @notice Fetches the max mint batch size.
    function getMaxMintBatchSize() external view returns (uint256);

    /// @notice Sets the max mint batch size.
    /// @param _maxMintBatchSize The new max mint batch size.
    function setMaxMintBatchSize(uint256 _maxMintBatchSize) external;

    /// @notice Mints a new token.
    function mint(bytes calldata listStorageLocation) external payable;

    /**
     * @notice Mints a new token to the given address.
     * @param to The address to mint the token to.
     */
    function mintTo(address to, bytes calldata listStorageLocation) external payable;

    /// @notice Mints a new token to the given address.
    function mintBatch(uint256 quantity) external payable;

    /// @notice Mints a new token to the given address.
    function mintBatchTo(address to, uint256 quantity) external payable;
}
