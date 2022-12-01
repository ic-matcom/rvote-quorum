// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.25 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

library Array {  // @FIXME rename to `DynamicOrStorageArray` or similar
    function toString(uint[] memory target) internal pure returns (string memory) {
        string memory str = "[";
        for (uint256 i = 0; i < target.length; i++) {
            str = string.concat(str, Strings.toString(target[i]), ", ");
        }
        str = string.concat(str, "]");
        return str;
    }

    function setValuesFromStaticArray(uint[] storage self, uint[5] memory source) 
        internal 
    {
        require(
            self.length >= source.length, 
            "Target array must be at least as long as the source array."
        );
        for (uint256 i = 0; i < source.length; i++) {
            self[i] = source[i];
        }
    }

    function setValuesFromArray(uint[] storage self, uint[] memory source) 
        internal 
    {
        require(
            self.length >= source.length, 
            "Target array must be at least as long as the source array."
        );
        for (uint256 i = 0; i < source.length; i++) {
            self[i] = source[i];
        }
    }

    function fromStaticArray(int32[5] memory source) 
        internal 
        pure 
        returns (int32[] memory newArray) 
    {
        uint length = source.length;
        newArray = new int32[](length);
        for (uint256 i = 0; i < length; i++) {
            newArray[i] = source[i];
        }
        return newArray;
    }

    function fromStaticArray(uint[5] memory source) internal pure returns (uint[] memory) {
        uint length = source.length;
        uint[] memory newArray = new uint[](length);
        for (uint256 i = 0; i < length; i++) {
            newArray[i] = source[i];
        }
        return newArray;
    }

    function fromStaticArray(uint[6] memory source) internal pure returns (uint[] memory) {
        uint length = source.length;
        uint[] memory newArray = new uint[](length);
        for (uint256 i = 0; i < length; i++) {
            newArray[i] = source[i];
        }
        return newArray;
    }

    function fromStaticArray(int32[6] memory source) internal pure returns (int32[] memory newArray) {
        uint length = source.length;
        newArray = new int32[](length);
        for (uint256 i = 0; i < length; i++) {
            newArray[i] = source[i];
        }
        return newArray;
    }

    function fromStaticArray(int32[13] memory source) internal pure returns (int32[] memory newArray) {
        uint length = source.length;
        newArray = new int32[](length);
        for (uint256 i = 0; i < length; i++) {
            newArray[i] = source[i];
        }
        return newArray;
    }

    function fromStaticArray(uint[13] memory source) internal pure returns (uint[] memory) {
        uint length = source.length;
        uint[] memory newArray = new uint[](length);
        for (uint256 i = 0; i < length; i++) {
            newArray[i] = source[i];
        }
        return newArray;
    }

    function max(uint[] memory data) internal pure returns (uint maxValue) {
        for (uint256 i = 0; i < data.length; i++) {
            maxValue = Math.max(data[i], maxValue);
        }
    }
}

// @TODO move all libraries to a `libs/` folder