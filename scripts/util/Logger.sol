// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";

import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {IERC721Enumerable} from "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import {BytesUtils} from "./BytesUtils.sol";
import {Colors} from "./Colors.sol";
import {ListOpUtils} from "./ListOpUtils.sol";
import {StringUtils} from "./StringUtils.sol";
import {Contracts} from "./Contracts.sol";

import {ListOp} from "../../src/ListOp.sol";
import {IEFPListMetadata} from "../../src/IEFPListMetadata.sol";
import {IEFPListRecords} from "../../src/IEFPListRecords.sol";

library Logger {
    using ListOpUtils for ListOp;

    function formatListOp(ListOp memory op) internal pure returns (string memory) {
        // Directly use op.data[0] and op.data[1] in the string.concat to reduce local variables
        string memory codeColor = op.code == 0x01
            ? Colors.GREEN
            : (
                op.code == 0x02
                    ? Colors.RED
                    : (op.code == 0x03 ? Colors.DARK_GREEN : (op.code == 0x04 ? Colors.DARK_RED : Colors.MAGENTA))
            );

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
            StringUtils.bytesToHexStringWithoutPrefix(BytesUtils.slice(op.data, 2, 20)),
            Colors.ENDC
        );
        // see if there is anything after the first 22 bytes
        if (op.data.length > 22) {
            s = string.concat(
                s,
                Colors.ORANGE,
                StringUtils.bytesToHexStringWithoutPrefix(BytesUtils.slice(op.data, 22, op.data.length - 22)),
                Colors.ENDC
            );
        }
        return s;
    }

    function logNFTs(address nftContract, uint256 start) internal view {
        IERC721Enumerable erc721 = IERC721Enumerable(nftContract);

        uint256 totalSupply = erc721.totalSupply();

        console.log();
        console.log("---------------------------------------------------------");
        console.log("|                     EFP List NFTs                     |");
        console.log("---------------------------------------------------------");
        console.log("| Token ID |                    Owner                   |");
        console.log("---------------------------------------------------------");

        for (uint256 j = start; j < totalSupply; j++) {
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

    function logListOps(Contracts memory contracts, uint256 start, uint256 end) internal view {
        console.log();
        console.log(
            "--------------------------------------------------------------------------------------------------"
        );
        console.log(
            "|                                           EFP Lists                                            |"
        );
        console.log(
            "--------------------------------------------------------------------------------------------------"
        );
        console.log(
            "|    Nonce    | Index | ListOp                                                   | Description   |"
        );
        console.log(
            "--------------------------------------------------------------------------------------------------"
        );

        for (uint256 tokenId = start; tokenId <= end; tokenId++) {
            bytes memory listLocation = IEFPListMetadata(contracts.listMetadata).getValue(tokenId, "efp.list.location");
            require(listLocation[0] == 0x01, "Logger: invalid list location version");
            require(listLocation[1] == 0x01, "Logger: invalid list location type");
            // load next 20 bytes as an address type
            address listLocationAddress = BytesUtils.toAddress(listLocation, 2);
            require(contracts.listRecords == listLocationAddress, "Logger: invalid list address");
            // now retrieve the 32-byte nonce at bytes 22-53
            uint256 nonce = BytesUtils.toUint256(listLocation, 22);

            // now we determine how many list ops are in the list
            uint256 listOpCount = IEFPListRecords(contracts.listRecords).getListOpCount(tokenId);

            for (uint256 i = 0; i < listOpCount; i++) {
                bytes memory listOpBytes = IEFPListRecords(contracts.listRecords).getListOp(tokenId, i);
                ListOp memory listOp = ListOpUtils.decode(listOpBytes);
                logListOpTableRow(nonce, i, listOp);
            }

            console.log(
                "--------------------------------------------------------------------------------------------------"
            );
        }
    }

    function logListOpTableRow(uint256 nonce, uint256 index, ListOp memory listOp) internal view {
        string memory line = string.concat("|      #", Strings.toString(nonce), "    ", (nonce < 10 ? " |" : "|"));

        // index
        line = string.concat(line, "   ", Strings.toString(index), "  ", (index < 10 ? " |" : "|"));

        // listOp
        line = string.concat(line, " ", Logger.formatListOp(listOp), " ");
        if (listOp.code == 0x01 || listOp.code == 0x02) {
            line = string.concat(line, "      |");
        } else {
            line = string.concat(line, "|");
        }

        string memory desc = listOp.description();
        line = string.concat(line, " ", desc, " |");

        console.log(line);
    }
}
