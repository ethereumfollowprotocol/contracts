// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @title IEFPListMetadata
 */
interface IEFPListMetadata {
    event ValueSet(uint indexed tokenId, string key, bytes value);

    /**
     * @title Key-value Record
     * @notice A key-value string pair.
     */
    struct KeyValue {
        string key;
        bytes value;
    }

    function getValue(
        uint tokenId,
        string calldata key
    ) external view returns (bytes memory);

    function setValue(
        uint tokenId,
        string calldata key,
        bytes calldata value
    ) external;

    function setValue2(
        uint tokenId,
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

    function setValues(uint tokenId, KeyValue[] calldata records) external;
}
