// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BytesUtils} from "../util/BytesUtils.sol";
import {CSVUtils} from "../util/CSVUtils.sol";
import {StringUtils} from "../util/StringUtils.sol";

/**
 * @title ListNFTsCsvLoader
 *
 * @notice ListNFTsCsvLoader is a helper contract to load list NFTs CSV files
 * into a mapping.
 */
contract ListNFTsCsvLoader {
    struct Row {
        uint tokenId;
        address listUser;
    }

    uint256 lastTokenId = 0;
    mapping(uint256 => Row) public loadedListNfts;

    // Helper function to parse the CSV and populate the recordsMapping
    function loadListNFTsCsv(string memory csv) internal {
        string[] memory lines = CSVUtils.split(csv, "\n");
        lastTokenId = 0; // Initialize lastTokenId to 0

        for (uint256 i = 1; i < lines.length; i++) {
            // Start from 1 to skip the header
            string memory line = lines[i];
            // Skip empty lines
            if (bytes(line).length == 0) {
                continue;
            }
            string[] memory values = CSVUtils.split(lines[i], ",");
            string memory tokenIdStr = values[0];
            string memory listUserStr = values[1];

            uint256 tokenId = StringUtils.stringToUint(tokenIdStr);
            address listUser = StringUtils.stringToAddress(listUserStr);
            require(tokenId >= lastTokenId, "tokenIds are not monotonically increasing");

            loadedListNfts[tokenId] = Row({tokenId: tokenId, listUser: listUser});

            lastTokenId = tokenId; // Update lastTokenId after processing the line
        }
    }
}
