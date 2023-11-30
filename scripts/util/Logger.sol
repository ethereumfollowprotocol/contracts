// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";

import {ListOp} from "../../src/beta/ListOp.sol";
import {BytesUtils} from "./BytesUtils.sol";
import {StringUtils} from "./StringUtils.sol";

import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {IERC721Enumerable} from "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

library Logger {


    function formatListOp(ListOp memory op) internal view returns (string memory) {
        // Directly use op.data[0] and op.data[1] in the string.concat to reduce local variables
        string memory codeColor = op.code == 0x01 ? StringUtils.GREEN : (op.code == 0x02 ? StringUtils.RED : StringUtils.MAGENTA);

        // Minimize the creation of new variables by directly manipulating and passing parameters
        string memory s = string.concat(
            "0x",
            StringUtils.YELLOW,
            StringUtils.byteToHexString(op.version),
            codeColor,
            StringUtils.byteToHexString(op.code),
            StringUtils.YELLOW,
            StringUtils.byteToHexString(uint8(op.data[0])));
        s = string.concat(s, StringUtils.MAGENTA, StringUtils.byteToHexString(uint8(op.data[1])));
        s = string.concat(s, StringUtils.CYAN, StringUtils.bytesToHexStringWithoutPrefix(BytesUtils.slice(op.data, 2, op.data.length - 2)), StringUtils.ENDC);
        return s;
    }

    function logNFTs(address nftContract) internal {
        IERC721Enumerable erc721 = IERC721Enumerable(nftContract);

        uint totalSupply = erc721.totalSupply();

        console.log("---------------------------------------------------------");
        console.log("| Token ID |                    Owner                   |");
        console.log("---------------------------------------------------------");

        for (uint j = 0; j < totalSupply; j++) {
            address owner = erc721.ownerOf(j);

            // Formatting the output as a row in the table
            string memory s = string.concat("|    #", Strings.toString(j), "   ");
            if (j < 10) {
                s = string.concat(s, " ");
            }

            console.log("%s| %s |", s, Strings.toHexString(uint256(uint160(owner)), 20));
            console.log("---------------------------------------------------------");
        }
    }

    // Modified for loop to print listOps in a tabular format
    function logListOps(uint start, uint end, mapping(uint => ListOp[]) storage listOpsMapping) public {
        string memory output;

        console.log("----------------------------------------------------------------------------");
        console.log("|    Nonce    | Index | ListOp                                             |");
        console.log("----------------------------------------------------------------------------");

        for (uint n = start; n <= end; n++) {
            ListOp[] memory listOps = listOpsMapping[n];

            for (uint i = 0; i < listOps.length; i++) {
                // nonce
                string memory line = string.concat("|      #", Strings.toString(n), "    ", (n < 10 ? " |" : "|"));

                // index
                line = string.concat(line, "   ", Strings.toString(i), "  ", (i < 10 ? " |" : "|"));

                // listOp
                line = string.concat(line, " ", Logger.formatListOp(listOps[i]), " |");
                console.log(line);
            }
            console.log("----------------------------------------------------------------------------");
        }
    }

}