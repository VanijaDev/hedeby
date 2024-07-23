// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { BarcodeInfo } from "../structs/BarcodeStructs.sol";

library ArrayBarcodeInfo {
  function removeAtIndex(BarcodeInfo[] storage _array, uint256 _index) internal {
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