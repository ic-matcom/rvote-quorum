// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.22 <0.9.0;

import "../contracts/InstantRunoffLib.sol";
import "./Array.sol";
import "../contracts/NegativeDefaultArray.sol";

library InstantRunoffLibTestCases {
    using Array for uint[];
    using InstantRunoffLibTestCases for TestCaseBuilder5Voters;

    struct TestCaseBuilder5Voters {
        int32[5] vote;
        uint[5] voteTimeValuesToSet;
        uint[5] votesAmount;
    }

    function noCycle5Voters(uint[] storage voteTime) 
        internal 
        returns (InstantRunoffSystem memory system) 
    {
        TestCaseBuilder5Voters memory builder = TestCaseBuilder5Voters({
            vote: [int32(1), 2, 3, -1, 2],
            voteTimeValuesToSet: [uint(7), 2, 3, 0, 5],
            votesAmount: [uint(0), 1, 3, 4, 0]
        });
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
        return builder.buildSystemFromVoteTime(voteTime);
    }

    function cycle3VotersOf5Total(uint[] storage voteTime) 
        internal 
        returns (InstantRunoffSystem memory system) 
    {
        TestCaseBuilder5Voters memory builder = TestCaseBuilder5Voters({
            vote: [int32(1), 2, 3, 1, 2],
            voteTimeValuesToSet: [uint(1), 4, 3, 2, 5],
            votesAmount: [uint(0), 4, 4, 4, 0]
        });
        //        -----<-
        //       /       \ 
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
        return builder.buildSystemFromVoteTime(voteTime);
    }

    function buildSystemFromVoteTime(
        TestCaseBuilder5Voters memory self, 
        uint[] storage voteTime
    )
        internal
        returns (InstantRunoffSystem memory system)
    {
        uint32[] memory vote = NegativeDefaultArray.buildFromStaticArray(self.vote);
        voteTime.setValuesFromStaticArray(self.voteTimeValuesToSet);
        uint[] memory votesAmount = Array.fromStaticArray(self.votesAmount);
        uint maxCount = Array.max(votesAmount);
        InstantRunoffSystemBuilder memory systemBuilder = InstantRunoffSystemBuilder({
            targetVotesAmount: maxCount,
            vote: vote,
            votesAmount: votesAmount
        });
        system = systemBuilder.buildFrom(voteTime);
    }
}