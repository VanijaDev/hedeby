// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

interface IProductCatalog {
  function barcodeExists(string memory _barcode) external view returns (bool);
}