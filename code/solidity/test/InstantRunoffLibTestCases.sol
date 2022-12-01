// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.22 <0.9.0;

import "../contracts/InstantRunoffLib.sol";
import "./Array.sol";
import "../contracts/NegativeDefaultArray.sol";

library InstantRunoffLibTestCases {
    using Array for uint[];
    using InstantRunoffLibTestCases for TestCaseBuilderVoters;

    struct TestCaseBuilderVoters {
        int32[] vote;
        uint[] voteTimeValuesToSet;
        uint[] votesAmount;
    }

    function getBuilderFromStaticArrays(
        int32[5] memory vote,
        uint[5] memory voteTimeValuesToSet,
        uint[5] memory votesAmount
    ) 
        private 
        pure 
        returns (TestCaseBuilderVoters memory builder) 
    {
        builder.vote = Array.fromStaticArray(vote);
        builder.voteTimeValuesToSet = Array.fromStaticArray(voteTimeValuesToSet);
        builder.votesAmount = Array.fromStaticArray(votesAmount);
    }

    function getBuilderFromStaticArrays(
        int32[13] memory vote,
        uint[13] memory voteTimeValuesToSet,
        uint[13] memory votesAmount
    ) 
        private 
        pure 
        returns (TestCaseBuilderVoters memory builder) 
    {
        builder.vote = Array.fromStaticArray(vote);
        builder.voteTimeValuesToSet = Array.fromStaticArray(voteTimeValuesToSet);
        builder.votesAmount = Array.fromStaticArray(votesAmount);
    }

    function noCycle5Voters(uint[] storage voteTime) 
        internal 
        returns (InstantRunoffSystem memory system) 
    {
        TestCaseBuilderVoters memory builder = getBuilderFromStaticArrays({
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
        TestCaseBuilderVoters memory builder = getBuilderFromStaticArrays({
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
        TestCaseBuilderVoters memory self, 
        uint[] storage voteTime
    )
        internal
        returns (InstantRunoffSystem memory system)
    {
        uint32[] memory vote = NegativeDefaultArray.buildFromArray(self.vote);
        voteTime.setValuesFromArray(self.voteTimeValuesToSet);
        uint[] memory votesAmount = self.votesAmount;
        uint maxCount = Array.max(votesAmount);
        InstantRunoffSystemBuilder memory systemBuilder = InstantRunoffSystemBuilder({
            targetVotesAmount: maxCount,
            vote: vote,
            votesAmount: votesAmount
        });
        system = systemBuilder.buildFrom(voteTime);
    }

    function twoCyclesTheLargestOf4Vertices13Total(uint[] storage voteTime) 
        internal 
        returns (InstantRunoffSystem memory system) 
    {
        TestCaseBuilderVoters memory builder = getBuilderFromStaticArrays({
            vote: [int32(2), 7, 12, 7, 8, 6, 4, 1, 10, 6, 11, 4, 10],
            voteTimeValuesToSet: [uint(3), 13, 7, 1, 12, 8, 11, 9, 5, 6, 10, 4, 2],
            votesAmount: [uint(0), 2, 1, 0, 9, 0, 2, 2, 9, 0, 9, 9, 2]
        });
        //      2     7    3
        //   10 <- 12 <- 2 <- 0
        //   |  \ 10                       9     1
        //   |   11                     1 <-> 7 <- 3
        // 5 ^    | 4                      13
        //   |    v      6
        //   8 <- 4 <- 6 <- 9
        //      12  11  \ 
        //               -<- 5
        //                8
        return builder.buildSystemFromVoteTime(voteTime);
    }
        
}