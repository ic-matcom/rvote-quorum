// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.22 <0.9.0;

import './TiedPerson.sol';

library Ranks {
    struct Data {
        uint targetCount;
        uint32 activeAmount;
    }

    function build(uint targetCount, uint32 ranksAmount) internal pure returns (Data memory ans) {
        revert('Not implemented');
    }

    function next(Data memory self, uint32 voterId) 
        internal 
        pure 
        returns (uint32 nextChoice, uint oldestVoteTime, bool emptyRank) 
    {
        revert('Not implemented');
    }

    function getFirst(Data memory self, uint32 voterId) 
        internal 
        pure 
        returns (uint32 firstChoice, bool emptyRank) 
    {
        revert('Not implemented');
    }

    function remove(Data memory self, TiedPerson.Data memory target) internal pure {
        revert('Not implemented');
    }
}