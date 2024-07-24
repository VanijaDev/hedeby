// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import { BarcodeInfo } from "./structs/BarcodeStructs.sol";
import { ProductCatalog } from "./ProductCatalog.sol";

/**
 * @title A catalog of facility locations.
 * @author Ivan Solomichev.
 * @dev Allows to add, remove, update location barcodes and their descriptions. Also, allows to change status of the barcode. 
 */
contract FacilityLocation is ProductCatalog { }