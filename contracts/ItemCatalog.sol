// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

contract ItemCatalog {
  struct Item {
    string uniqueId; // TODO: used for QR generation, tracking, etc.
    string barcode;
  }

  mapping(string => Item) public itemCountForBarcode;

  // add item to catalog
  // remove item from catalog
  
}