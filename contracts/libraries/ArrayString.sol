// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;


library ArrayString {
  function removeAtIndex(string[] storage _array, uint256 _index) internal {
    uint256 len = _array.length;

    if (_index >= len) {
      return;
    }

    if (_index < len - 1) {
      _array[_index] = _array[len - 1];
    }

    _array.pop();
  }
}