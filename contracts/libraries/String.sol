// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;


library String {
  function isEmpty(string memory a) internal pure returns (bool) {
    return bytes(a).length == 0;
  }

  function compare(string memory a, string memory b) internal pure returns (bool) {
    return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
  }
}