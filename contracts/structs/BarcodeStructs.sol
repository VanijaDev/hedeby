// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

 struct ItemBarcodeInfo {
    string barcode;
    string description;
  }

  struct ItemBarcodeDetails {
    bool active;
    uint256 barcodesInfoIndex;
    string barcode;
    string description;
  }