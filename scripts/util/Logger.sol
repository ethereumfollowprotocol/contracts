// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import 'forge-std/console.sol';

import {Strings} from 'lib/openzeppelin-contracts/contracts/utils/Strings.sol';
import {IERC721Enumerable} from 'lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol';

import {BytesUtils} from './BytesUtils.sol';
import {Colors} from './Colors.sol';
import {ListOpUtils} from './ListOpUtils.sol';
import {StringUtils} from './StringUtils.sol';
import {Contracts} from './Contracts.sol';

import {ListOp} from '../../src/types/ListOp.sol';
import {IEFPListRegistry} from '../../src/interfaces/IEFPListRegistry.sol';
import {IEFPListRecords} from '../../src/interfaces/IEFPListRecords.sol';

library Logger {
  using ListOpUtils for ListOp;

  function formatListOp(ListOp memory op) internal pure returns (string memory) {
    // Directly use op.data[0] and op.data[1] in the string.concat to reduce local variables
    string memory codeColor = op.opcode == 0x01
      ? Colors.GREEN
      : (
        op.opcode == 0x02
          ? Colors.RED
          : (op.opcode == 0x03 ? Colors.DARK_GREEN : (op.opcode == 0x04 ? Colors.DARK_RED : Colors.MAGENTA))
      );

    // Minimize the creation of new variables by directly manipulating and passing parameters
    string memory s = string.concat(
      '0x',
      Colors.YELLOW,
      StringUtils.byteToHexString(op.version),
      codeColor,
      StringUtils.byteToHexString(op.opcode),
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

  function logNFTs(Contracts memory contracts, uint256 start) internal view {
    IERC721Enumerable erc721 = IERC721Enumerable(contracts.listRegistry);

    uint256 totalSupply = erc721.totalSupply();
    console.log();
    console.log(
      '---------------------------------------------------------------------------------------------------------------------------------------------------'
    );
    console.log(
      '|                                                            EFP List NFTs                                                                       |'
    );
    console.log(
      '---------------------------------------------------------------------------------------------------------------------------------------------------'
    );
    console.log(
      '| Token ID |                    Owner                   |                   Manager                  |                    User                    |'
    );
    console.log(
      '---------------------------------------------------------------------------------------------------------------------------------------------------'
    );

    for (uint256 j = start; j < totalSupply; j++) {
      address owner = erc721.ownerOf(j);
      address listManager = IEFPListRecords(contracts.listRecords).getListManager(j);
      bytes memory userBytes = IEFPListRecords(contracts.listRecords).getMetadataValue(j, 'user');
      require(userBytes.length == 20, 'Logger: invalid user bytes');
      // this line isn't working?
      address listUser = BytesUtils.toAddress(userBytes, 0);

      // Formatting the output as a row in the table
      string memory s = string.concat('|    #', Strings.toString(j), '   ');
      if (j < 10) {
        s = string.concat(s, ' ');
      }
      s = string.concat(
        s,
        '| ',
        StringUtils.addressToString(owner),
        ' | ',
        StringUtils.addressToString(listManager),
        ' | ',
        StringUtils.addressToString(listUser),
        ' |'
      );
      console.log(s);
      console.log(
        '---------------------------------------------------------------------------------------------------------------------------------------------------'
      );
    }
  }

  function logListOps(Contracts memory contracts, uint256 start, uint256 end) internal view {
    console.log();
    console.log('----------------------------------------------------------------------------------------------------');
    console.log('|                                            EFP Lists                                             |');
    console.log('----------------------------------------------------------------------------------------------------');
    console.log('|    Nonce    | Index | ListOp                                                     | Description   |');
    console.log('----------------------------------------------------------------------------------------------------');

    for (uint256 tokenId = start; tokenId <= end; tokenId++) {
      bytes memory listStorageLocation = IEFPListRegistry(contracts.listRegistry).getListStorageLocation(tokenId);
      require(listStorageLocation.length > 0, 'Logger: invalid list storage location');
      require(listStorageLocation[0] == 0x01, 'Logger: invalid list location version');
      require(listStorageLocation[1] == 0x01, 'Logger: invalid list location type');
      // load the next 32 bytes as chain id, bytes 2-33
      // uint256 chainId = BytesUtils.toUint256(listStorageLocation, 2);
      // load next 20 bytes as an address type, bytes 34-53
      address listStorageLocationAddress = BytesUtils.toAddress(listStorageLocation, 34);
      require(contracts.listRecords == listStorageLocationAddress, 'Logger: invalid list address');
      // now retrieve the 32-byte slot at bytes 54-85
      uint256 slot = BytesUtils.toUint256(listStorageLocation, 54);

      // now we determine how many list ops are in the list
      uint256 listOpCount = IEFPListRecords(contracts.listRecords).getListOpCount(tokenId);

      for (uint256 i = 0; i < listOpCount; i++) {
        bytes memory listOpBytes = IEFPListRecords(contracts.listRecords).getListOp(tokenId, i);
        ListOp memory listOp = ListOpUtils.decode(listOpBytes);
        logListOpTableRow(slot, i, listOp);
      }

      console.log(
        '----------------------------------------------------------------------------------------------------'
      );
    }
  }

  function logListOpTableRow(uint256 slot, uint256 index, ListOp memory listOp) internal view {
    string memory line = string.concat('|      #', Strings.toString(slot), '    ', (slot < 10 ? ' |' : '|'));

    // index
    line = string.concat(line, '   ', Strings.toString(index), '  ', (index < 10 ? ' |' : '|'));

    // listOp
    line = string.concat(line, ' ', Logger.formatListOp(listOp), ' ');
    if (listOp.opcode == 0x01 || listOp.opcode == 0x02) {
      line = string.concat(line, '        |');
    } else if (listOp.opcode == 0x03 || listOp.opcode == 0x04) {
      line = string.concat(line, '|');
    }

    // description
    string memory desc = listOp.description();
    line = string.concat(line, ' ', desc, ' |');

    console.log(line);
  }
}
