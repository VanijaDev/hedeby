// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

 struct BarcodeInfo {
    string barcode;
    string description;
  }

  struct BarcodeDetails {
    bool active;
    uint256 barcodesInfoIndex;
    string barcode;
    string description;
  }