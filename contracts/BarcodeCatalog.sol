// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { String } from "./libraries/String.sol";

// import "hardhat/console.sol";

contract BarcodeCatalog is Ownable {
  using String for string;

  struct Barcode {
    bool active;
    string barcode;
    string description;
  }

  Barcode[] public barcodes;
  mapping(string => Barcode) public barcodeDetails;

  event BarcodeAdded(string indexed barcode);
  event BarcodeRemoved(string indexed barcode);
  event BarcodeDescriptionUpdated(string indexed barcode);
  event BarcodeStatusUpdated(string indexed barcode, bool active);

  modifier barcodeExists(string memory _barcode) {
    require(!barcodeDetails[_barcode].barcode.isEmpty(), "Barcode does not exist");
    _;
  }

  constructor() Ownable(msg.sender) {}

  /**
   * @dev Adds barcodes to the catalog.
   * @param _barcodes Barcodes to add.
   * @param _descriptions Descriptions for the barcodes.
   */
  function addBarcodes(string[] memory _barcodes, string[] memory _descriptions) external onlyOwner {
    require(_barcodes.length == _descriptions.length, "Length mismatch");

    uint256 len = _barcodes.length;
    for (uint256 i = 0; i < len; ++i) {
      require(barcodeDetails[_barcodes[i]].barcode.isEmpty(), "Barcode already exists"); // TODO: use custom errors

      Barcode memory barcode = Barcode(true, _barcodes[i], _descriptions[i]);
      barcodes.push(barcode);
      barcodeDetails[_barcodes[i]] = barcode;

      emit BarcodeAdded(_barcodes[i]);
    }
  }

  /**
   * @dev Change barcode status.
   * @param _barcode Barcode to change status.
   * @param _active Status to be set.
   */
  function changeBarcodeStatus(string memory _barcode, bool _active) external onlyOwner barcodeExists(_barcode) {
    barcodeDetails[_barcode].active = _active;

    emit BarcodeStatusUpdated(_barcode, _active);
  }

  /**
   * @dev Update barcode description.
   * @param _barcode Barcode to update description.
   * @param _description Description to be used.
   */
  function updateBarcodeDescription(string memory _barcode, string memory _description) external onlyOwner barcodeExists(_barcode) {
    barcodeDetails[_barcode].description = _description;

    emit BarcodeDescriptionUpdated(_barcode);
  }

  /**
   * @dev Get barcodes.
   * @param _startIndex Start index.
   * @param _endIndex End index.
   */
  function getBarcodes(uint256 _startIndex, uint256 _endIndex) external view returns (Barcode[] memory) {
    require(_startIndex < _endIndex, "Invalid range");

    uint256 len = barcodes.length;
    require(_endIndex <= len, "Out of range");

    Barcode[] memory result = new Barcode[](_endIndex - _startIndex);

    // TODO: test gas usage
    uint256 startIndex = _startIndex;
    uint256 endIndex = _endIndex;

    for (uint256 i = startIndex; i < endIndex; ++i) {
      result[i - startIndex] = barcodes[i];
    }

    return result;
  }
}
