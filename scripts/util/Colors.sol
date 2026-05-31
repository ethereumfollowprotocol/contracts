// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

library Colors {
  string public constant RED = '\x1b[31m';
  string public constant GREEN = '\x1b[32m';
  string public constant YELLOW = '\x1b[33m';
  string public constant BLUE = '\x1b[34m';
  string public constant MAGENTA = '\x1b[35m';
  string public constant CYAN = '\x1b[36m';
  string public constant ENDC = '\x1b[0m';
  string public constant ORANGE = '\x1b[38;2;255;165;0m';
  string public constant DARK_GREEN = '\x1b[38;2;0;128;0m';
  string public constant DARK_RED = '\x1b[38;2;128;0;0m';
}
