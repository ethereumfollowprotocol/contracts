// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title IEFPListMetadata
 */
interface IEFPListMetadata {
    function getEFPListRegistry() external view returns (address);

    function setEFPListRegistry(address efpListRegistry_) external;

    function addProxy(address proxy) external;

    function removeProxy(address proxy) external;

    function isProxy(address proxy) external view returns (bool);

    event ValueSet(uint256 indexed tokenId, string key, bytes value);

    /**
     * @title Key-value Record
     * @notice A key-value string pair.
     */
    struct KeyValue {
        string key;
        bytes value;
    }

    function getValue(uint256 tokenId, string calldata key) external view returns (bytes memory);

    function setValue(uint256 tokenId, string calldata key, bytes calldata value) external;

    function setValue2(
        uint256 tokenId,
        string calldata key,
        bytes calldata value,
        string calldata key2,
        bytes calldata value2
    ) external;

    // function setValue3(
    //   uint tokenId,
    //   string calldata key,
    //   bytes calldata value,
    //   string calldata key2,
    //   bytes calldata value2,
    //   string calldata key3,
    //   bytes calldata value3
    // ) external;

    function setValues(uint256 tokenId, KeyValue[] calldata records) external;
}
