// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IProductCatalog } from "./interfaces/IProductCatalog.sol";

/**
 * @title A catalog of items.
 * @author Ivan Solomichev.
 * @dev Allows to add, remove, update item count in the catalog.
 */
contract ItemCatalog is Ownable {
  struct Item {
    string id; // TODO: used for QR generation, tracking, etc.
    string description;
    string productBarcode;
    string locationBarcode;
  }

  IProductCatalog public productCatalog;

  mapping(string => string) public productBarcodeForItemId;
  // TODO: update check if item id is available
  mapping(string => Item[]) public itemsForProductBarcode;
  mapping(string => uint256) public positionIndexFortIemId;

  event ItemReceived(string indexed id, string indexed productBarcode);
  event ItemDescriptionUpdated(string indexed id, string indexed productBarcode);
  event ItemMoved(string indexed id, string indexed productBarcode, string indexed warehouseLocationBarcode);
  event ItemRemoved(string indexed id, string indexed productBarcode);

  modifier onlyItemIdUsed(string memory _id) {
    require(isItemIdUsed(_id), "Item id does not exist");
    _;
  }

  modifier onlyItemIdNoUsed(string memory _id) {
    require(!isItemIdUsed(_id), "Item id already exists");
    _;
  }

  modifier onlyValidBarcode(string memory _barcode) {
    require(productCatalog.barcodeExists(_barcode), "Barcode does not exist");
    _;
  }

  modifier onlyValidArgsForReceiveItem(string memory _id, string memory _description) {
    require(bytes(_id).length > 0, "Item id is required");
    require(!isItemIdUsed(_id), "Item id already exists");
    // productBarcode should be checked before
    _;
  }

  modifier onlyItemPresentInCatalog(string memory _id, string memory _productBarcode) {
    require(itemPresentInCatalog(_id, _productBarcode), "Item is not present");
    _;
  }

  /**
   * @dev Constructor.
   * @param _productCatalog Product catalog address.
   */
  constructor(address _productCatalog) Ownable(msg.sender) {
    productCatalog = IProductCatalog(_productCatalog);
  }

  /**
   * @dev Updates product catalog address.
   * @param _productCatalog Product catalog address.
   */
  function updateProductCatalog(address _productCatalog) external onlyOwner {
    productCatalog = IProductCatalog(_productCatalog);
  }

  function isItemIdUsed(string memory _id) public view returns (bool) {
    return keccak256(abi.encodePacked(productBarcodeForItemId[_id])).length > 0;
  }

  /**
   * @dev Gets number of items for product barcode.
   * @param productBarcode Product barcode.
   * @return uint256 Number of items for product barcode.
   */
  function countOfItemsForProductBarcode(string memory productBarcode) public view returns (uint256) {
    return itemsForProductBarcode[productBarcode].length;
  }

  /**
    * @dev Checks if item id is present in the catalog.
    * @param _id Item id.
    * @param _productBarcode Product barcode.
    * @return bool Whether item id is present in the catalog.
    */
  function itemPresentInCatalog(string memory _id, string memory _productBarcode) public view returns (bool) {
    if (!isItemIdUsed(_id)) {
      return false;
    }

    uint256 index = positionIndexFortIemId[_id];
    if (index == 0) {
      string storage productBarcodeStored = itemsForProductBarcode[_productBarcode][index].productBarcode;
      return keccak256(abi.encodePacked(productBarcodeStored)) == keccak256(abi.encodePacked(_productBarcode));
    }

    return true;
  }

  /**
   * @dev Receives items.
   * @param _ids Item ids.
   * @param _descriptions Item descriptions.
   * @param _productBarcode Product barcode.
   */
  function receiveItems(string[] memory _ids, string[] memory _descriptions, string memory _productBarcode) external onlyValidBarcode(_productBarcode) {
    require(_ids.length == _descriptions.length, "Wrong lengths");

    uint256 len = _ids.length;
    for (uint256 i = 0; i < len; i++) {
      _receiveItem(_ids[i], _descriptions[i], _productBarcode);
    }
  }

  /**
   * @dev Updates item description.
   * @param _id Item id.
   * @param _productBarcode Product barcode.
   * @param _description Item description.
   */
  function updateItemDescription(string memory _id, string memory _productBarcode, string memory _description) external onlyItemPresentInCatalog(_id, _productBarcode) {
    uint256 index = positionIndexFortIemId[_id];
    itemsForProductBarcode[_productBarcode][index].description = _description;

    emit ItemDescriptionUpdated(_id, _productBarcode);
  }



  // Private functions

  /**
   * @dev Receives an item.
   * @param _id Item id.
   * @param _description Item description.
   * @param _productBarcode Product barcode.
   */
  function _receiveItem(string memory _id, string memory _description, string memory _productBarcode) private onlyValidArgsForReceiveItem(_id, _description) {
    // isItemIdUsed(_id) == true;
  
    // positionIndexFortIemId[_id] = itemsForProductBarcode[_productBarcode].length;
    // itemsForProductBarcode[_productBarcode].push(Item(_id, _description, _productBarcode, ""));
  
    // emit ItemReceived(_id, _productBarcode);
  }
}