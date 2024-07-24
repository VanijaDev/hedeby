// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { ArrayString } from "./libraries/ArrayString.sol";
import { ArrayBarcodeInfo } from "./libraries/ArrayBarcodeInfo.sol";
import { BarcodeInfo, BarcodeDetails } from "./structs/BarcodeStructs.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IProductCatalog } from "./interfaces/IProductCatalog.sol";
import { String } from "./libraries/String.sol";

// import "hardhat/console.sol";

/**
 * @title A catalog of products.
 * @author Ivan Solomichev.
 * @dev Allows to add, remove, update product barcodes and their descriptions. Also, allows to change status of the barcode. 
 */
contract ProductCatalog is IProductCatalog, Ownable {
  using String for string;
  using ArrayString for string[];
  using ArrayBarcodeInfo for BarcodeInfo[];


  BarcodeInfo[] public barcodesInfo;
  string[] public activeBarcodes;
  string[] public inactiveBarcodes;

  mapping(string => uint256) public barcodeInfoIndex;

  mapping(string => uint256) private activeBarcodeIndex;
  mapping(string => uint256) private inactiveBarcodeIndex;

  event BarcodeAdded(string indexed barcode);
  event BarcodeRemoved(string indexed barcode);
  event BarcodeDescriptionUpdated(string indexed barcode);
  event BarcodeStatusUpdated(string indexed barcode, bool active);

  modifier onlyBarcodeExists(string memory _barcode) {
    require(barcodeExists(_barcode), "Barcode does not exist"); // TODO: use custom errors
    _;
  }

  modifier onlyBarcodeActive(string memory _barcode) {
    require(isBarcodeActive(_barcode), "Barcode is not active");
    _;
  }

  modifier onlyBarcodeInactive(string memory _barcode) {
    require(isBarcodeInactive(_barcode), "Barcode is not inactive");
    _;
  }

  constructor() Ownable(msg.sender) {}

  /**
   * @dev Checks if barcode exists.
   * @param _barcode Barcode to check.
   * @return Whether barcode exists.
   */
  function barcodeExists(string memory _barcode) public view returns (bool) {
    return isBarcodeActive(_barcode) || isBarcodeInactive(_barcode);
  }

  /**
   * @dev Checks if barcode is active.
   * @param _barcode Barcode to check.
   * @return bool Whether barcode is active.
   */
  function isBarcodeActive(string memory _barcode) public view returns (bool) {
    uint256 index = activeBarcodeIndex[_barcode];

    return index > 0 ? true : activeBarcodes[index].isEqual(_barcode); // TODO: test gas usage with if - else
  }

  /**
   * @dev Checks if barcode is inactive.
   * @param _barcode Barcode to check.
   * @return bool Whether barcode is inactive.
   */
  function isBarcodeInactive(string memory _barcode) public view returns (bool) {
    uint256 index = inactiveBarcodeIndex[_barcode];

    return index > 0 ? true : inactiveBarcodes[index].isEqual(_barcode); // TODO: test gas usage with if - else
  }

  /**
   * @dev Adds barcodes to the catalog.
   * @param _barcodes Barcodes to add.
   * @param _descriptions Descriptions for the barcodes.
   */
  function addBarcodes(string[] memory _barcodes, string[] memory _descriptions) external onlyOwner {
    require(_barcodes.length == _descriptions.length, "Length mismatch");

    uint256 len = _barcodes.length;
    for (uint256 i = 0; i < len; ++i) {
      string memory barcode = _barcodes[i];
      require(!barcodeExists(barcode), "Barcode already exists");

      barcodeInfoIndex[barcode] = barcodesInfo.length;
      activeBarcodeIndex[barcode] = activeBarcodes.length;

      barcodesInfo.push( BarcodeInfo(barcode, _descriptions[i]) );
      activeBarcodes.push(barcode);

      emit BarcodeAdded(barcode);
    }
  }

  /**
   * @dev Change barcode status.
   * @param _active Status to be set.
   * @param _barcode Barcode to change status.
   */
  function changeBarcodeStatus(bool _active, string memory _barcode) external onlyOwner onlyBarcodeExists(_barcode) {
    _active ? changeBarcodeStatusToInactive(_barcode) : changeBarcodeStatusToActive(_barcode);

    // if (isBarcodeActive(_barcode) && _active == false) {
    //   uint256 index = activeBarcodeIndex[_barcode];
    //   delete activeBarcodeIndex[_barcode];

    //   activeBarcodes.removeAtIndex(index);

    //   inactiveBarcodeIndex[_barcode] = inactiveBarcodes.length;
    //   inactiveBarcodes.push(_barcode);
    // } else if (isBarcodeInactive(_barcode) && _active == true) {
    //   uint256 index = inactiveBarcodeIndex[_barcode];
    //   delete inactiveBarcodeIndex[_barcode];

    //   inactiveBarcodes.removeAtIndex(index);

    //   activeBarcodeIndex[_barcode] = activeBarcodes.length;
    //   activeBarcodes.push(_barcode);
    // } else {
    //   revert("Invalid status change");
    // }

    emit BarcodeStatusUpdated(_barcode, _active);
  }

  /**
   * @dev Update barcode description.
   * @param _barcode Barcode to update description.
   * @param _description Description to be used.
   */
  function updateBarcodeDescription(string memory _barcode, string memory _description) external onlyOwner onlyBarcodeExists(_barcode) {
    barcodesInfo[barcodeInfoIndex[_barcode]].description = _description;

    emit BarcodeDescriptionUpdated(_barcode);
  }

  /**
   * @dev Remove barcode from the catalog.
   * @param _barcode Barcode to remove.
   */
  function removeBarcode(string memory _barcode) external onlyOwner onlyBarcodeExists(_barcode) {
    uint256 index = barcodeInfoIndex[_barcode];
    delete barcodeInfoIndex[_barcode];
    barcodesInfo.removeAtIndex(index);

    if (isBarcodeActive(_barcode)) {
      uint256 activeIndex = activeBarcodeIndex[_barcode];
      delete activeBarcodeIndex[_barcode];

      activeBarcodes.removeAtIndex(activeIndex);
    } else {
      uint256 inactiveIndex = inactiveBarcodeIndex[_barcode];
      delete inactiveBarcodeIndex[_barcode];

      inactiveBarcodes.removeAtIndex(inactiveIndex);
    }

    emit BarcodeRemoved(_barcode);
  }

  /**
   * @dev Get barcode info.
   * @param _startIndex Start index.
   * @param _length Length.
   * @return BarcodeInfo Barcode info.
   */
  function getBarcodesInfo(uint256 _startIndex, uint256 _length) external view returns (BarcodeInfo[] memory) {
    BarcodeInfo[] storage _barcodesInfo = barcodesInfo;
    uint256 len = _length;

    if (_startIndex + len > _barcodesInfo.length) {
      _length = _barcodesInfo.length - _startIndex;
    }

    BarcodeInfo[] memory result = new BarcodeInfo[](_length);
    for (uint256 i = 0; i < _length; ++i) {
      result[i] = _barcodesInfo[_startIndex + i];
    }

    return result;
  }

  /**
   * @dev Get active barcodes.
   * @param _startIndex Start index.
   * @param _length Length.
   * @return stirng[] Active barcodes.
   */
  function getActiveBarcodes(uint256 _startIndex, uint256 _length) external view returns (string[] memory) {
    string[] storage _activeBarcodes = activeBarcodes;
    uint256 len = _length;

    if (_startIndex + len > _activeBarcodes.length) {
      _length = _activeBarcodes.length - _startIndex;
    }

    string[] memory result = new string[](_length);
    for (uint256 i = 0; i < _length; ++i) {
      result[i] = activeBarcodes[_startIndex + i];
    }

    return result;
  }

  /**
   * @dev Get active barcodes details.
   * @param _startIndex Start index.
   * @param _length Length.
   * @return BarcodeDetails[] Active barcodes details.
   */
  function getActiveBarcodesDetails(uint256 _startIndex, uint256 _length) external view returns (BarcodeDetails[] memory) {
    string[] storage _activeBarcodes = activeBarcodes;
    uint256 len = _length;

    if (_startIndex + len > _activeBarcodes.length) {
      _length = _activeBarcodes.length - _startIndex;
    }

    BarcodeInfo[] storage _barcodesInfo = barcodesInfo;
    BarcodeDetails[] memory result = new BarcodeDetails[](_length);

    for (uint256 i = 0; i < _length; ++i) {
      string memory barcode = activeBarcodes[_startIndex + i]; // TODO: test gas usage
      result[i] = BarcodeDetails(true, barcodeInfoIndex[barcode], barcode, _barcodesInfo[barcodeInfoIndex[barcode]].description);
    }

    return result;
  }

  /**
   * @dev Get inactive barcodes.
   * @param _startIndex Start index.
   * @param _length Length.
   * @return string[] Inactive barcodes.
   */
  function getInactiveBarcodes(uint256 _startIndex, uint256 _length) external view returns (string[] memory) {
    string[] storage _inactiveBarcodes = inactiveBarcodes;
    uint256 len = _length;

    if (_startIndex + len > _inactiveBarcodes.length) {
      _length = _inactiveBarcodes.length - _startIndex;
    }

    string[] memory result = new string[](_length);
    for (uint256 i = 0; i < _length; ++i) {
      result[i] = inactiveBarcodes[_startIndex + i];
    }

    return result;
  }

  /**
   * @dev Get inactive barcodes details.
   * @param _startIndex Start index.
   * @param _length Length.
   * @return BarcodeDetails[] Inactive barcodes details.
   */
  function getInactiveBarcodesDetails(uint256 _startIndex, uint256 _length) external view returns (BarcodeDetails[] memory) {
    string[] storage _inactiveBarcodes = inactiveBarcodes;
    uint256 len = _length;

    if (_startIndex + len > _inactiveBarcodes.length) {
      _length = _inactiveBarcodes.length - _startIndex;
    }

    BarcodeInfo[] storage _barcodesInfo = barcodesInfo;
    BarcodeDetails[] memory result = new BarcodeDetails[](_length);

    for (uint256 i = 0; i < _length; ++i) {
      string memory barcode = inactiveBarcodes[_startIndex + i]; // TODO: test gas usage
      result[i] = BarcodeDetails(false, barcodeInfoIndex[barcode], barcode, _barcodesInfo[barcodeInfoIndex[barcode]].description);
    }

    return result;
  }

  /**
   * @dev Change barcode status to active.
   * @param _barcode Barcode to change status.
   */
  function changeBarcodeStatusToActive(string memory _barcode) private onlyBarcodeInactive(_barcode) {
    uint256 index = inactiveBarcodeIndex[_barcode];
    delete inactiveBarcodeIndex[_barcode];

    inactiveBarcodes.removeAtIndex(index);

    activeBarcodeIndex[_barcode] = activeBarcodes.length;
    activeBarcodes.push(_barcode);
  }

  /**
   * @dev Change barcode status to inactive.
   * @param _barcode Barcode to change status.
   */
  function changeBarcodeStatusToInactive(string memory _barcode) private onlyBarcodeActive(_barcode) {
    uint256 index = activeBarcodeIndex[_barcode];
    delete activeBarcodeIndex[_barcode];

    activeBarcodes.removeAtIndex(index);

    inactiveBarcodeIndex[_barcode] = inactiveBarcodes.length;
    inactiveBarcodes.push(_barcode);
  }
}
