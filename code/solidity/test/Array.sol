// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.25 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";

library Array {
    function toString(uint[] memory data) internal pure returns (string memory) {
        string memory str = '[';
        for (uint256 i = 0; i < data.length; i++) {
            str = string.concat(str, Strings.toString(data[i]), ', ');
        }
        str = string.concat(str, ']');
        return str;
    }
}