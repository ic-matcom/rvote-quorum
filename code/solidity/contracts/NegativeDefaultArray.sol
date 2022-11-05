// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.22 <0.9.0;

int32 constant DEFAULT_ELEMENT = -1;

/// @dev This is a data structure for storing unsigned integers. Default value,
/// however, it's a negative number, so 0 can be stored in the structure. An instance
/// of `n` default elements can be built as fast as an array of `n` zeroes can be.
library NegativeDefaultArray {
    function build(uint32 size) internal pure returns (uint32[] memory) {
        return new uint32[](size+1);
    }

    function setAt(uint32[] memory self, uint32 index, int32 value) internal pure {
        self[index+1] = uint32(value+1);
    }

    function setAt(uint32[] memory self, uint32 index, uint32 value) internal pure {
        self[index+1] = value+1;
    }

    function getAt(uint32[] memory self, uint32 index) internal pure returns (int32) {
        return int32(self[index+1])-1;
    }
}