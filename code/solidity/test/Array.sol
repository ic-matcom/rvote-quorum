// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.25 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

library Array {  // @FIXME rename to `DynamicOrStorageArray` or similar
    function toString(uint[] memory data) internal pure returns (string memory) {
        string memory str = "[";
        for (uint256 i = 0; i < data.length; i++) {
            str = string.concat(str, Strings.toString(data[i]), ", ");
        }
        str = string.concat(str, "]");
        return str;
    }

    function setValuesFromStaticArray(uint[] storage self, uint[5] memory data) 
        internal 
    {
        for (uint256 i = 0; i < data.length; i++) {
            self[i] = data[i];
        }
    }

    function fromStaticArray(uint[5] memory data) internal pure returns (uint[] memory) {
        uint length = data.length;
        uint[] memory newArray = new uint[](length);
        for (uint256 i = 0; i < length; i++) {
            newArray[i] = data[i];
        }
        return newArray;
    }

    function max(uint[] memory data) internal pure returns (uint maxValue) {
        for (uint256 i = 0; i < data.length; i++) {
            maxValue = Math.max(data[i], maxValue);
        }
    }
}