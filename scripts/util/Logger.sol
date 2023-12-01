// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";

import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {IERC721Enumerable} from "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import {BytesUtils} from "./BytesUtils.sol";
import {Colors} from "./Colors.sol";
import {StringUtils} from "./StringUtils.sol";

import {ListOp} from "../../src/beta/ListOp.sol";

library Logger {
    function formatListOp(ListOp memory op) internal pure returns (string memory) {
        // Directly use op.data[0] and op.data[1] in the string.concat to reduce local variables
        string memory codeColor = op.code == 0x01 ? Colors.GREEN : (op.code == 0x02 ? Colors.RED : Colors.MAGENTA);

        // Minimize the creation of new variables by directly manipulating and passing parameters
        string memory s = string.concat(
            "0x",
            Colors.YELLOW,
            StringUtils.byteToHexString(op.version),
            codeColor,
            StringUtils.byteToHexString(op.code),
            Colors.YELLOW,
            StringUtils.byteToHexString(uint8(op.data[0]))
        );
        s = string.concat(s, Colors.MAGENTA, StringUtils.byteToHexString(uint8(op.data[1])));
        s = string.concat(
            s,
            Colors.CYAN,
            StringUtils.bytesToHexStringWithoutPrefix(BytesUtils.slice(op.data, 2, op.data.length - 2)),
            Colors.ENDC
        );
        return s;
    }

    function logNFTs(address nftContract) internal view {
        IERC721Enumerable erc721 = IERC721Enumerable(nftContract);

        uint256 totalSupply = erc721.totalSupply();

        console.log();
        console.log("---------------------------------------------------------");
        console.log("|                     EFP List NFTs                     |");
        console.log("---------------------------------------------------------");
        console.log("| Token ID |                    Owner                   |");
        console.log("---------------------------------------------------------");

        for (uint256 j = 0; j < totalSupply; j++) {
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
    function logListOps(uint256 start, uint256 end, mapping(uint256 => ListOp[]) storage listOpsMapping)
        internal
        view
    {
        console.log();
        console.log("--------------------------------------------------------------------------------------------");
        console.log("|                                        EFP Lists                                         |");
        console.log("--------------------------------------------------------------------------------------------");
        console.log("|    Nonce    | Index | ListOp                                             | Description   |");
        console.log("--------------------------------------------------------------------------------------------");

        for (uint256 n = start; n <= end; n++) {
            ListOp[] memory listOps = listOpsMapping[n];

            for (uint256 i = 0; i < listOps.length; i++) {
                // nonce
                string memory line = string.concat("|      #", Strings.toString(n), "    ", (n < 10 ? " |" : "|"));

                // index
                line = string.concat(line, "   ", Strings.toString(i), "  ", (i < 10 ? " |" : "|"));

                // listOp
                line = string.concat(line, " ", Logger.formatListOp(listOps[i]), " |");

                // description
                // 0x01 - add record
                // 0x02 - remove record
                // 0x03 - tag record
                // 0x04 - untag record
                string memory desc = "";
                if (listOps[i].code == 0x01) {
                    desc = string.concat(Colors.GREEN, "add record   ", Colors.ENDC);
                } else if (listOps[i].code == 0x02) {
                    desc = string.concat(Colors.RED, "remove record", Colors.ENDC);
                } else if (listOps[i].code == 0x03) {
                    desc = string.concat(Colors.GREEN, "tag record   ", Colors.ENDC);
                } else if (listOps[i].code == 0x04) {
                    desc = string.concat(Colors.RED, "untag record ", Colors.ENDC);
                }
                line = string.concat(line, " ", desc, " |");

                console.log(line);
            }

            console.log("--------------------------------------------------------------------------------------------");
        }
    }
}
