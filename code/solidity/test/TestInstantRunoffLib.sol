// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.25 <0.9.0;

import "truffle/Assert.sol";
import "../contracts/InstantRunoffLib.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "../contracts/NegativeDefaultArray.sol";
import "./InstantRunoffLibTestCases.sol";

contract TestInstantRunoffLib {
    using InstantRunoffLib for InstantRunoffSystem;
    using InstantRunoffLib for InstantRunoffSystemBuilder;
    using NegativeDefaultArray for uint32[];

    uint[] voteTime;

    function testGetFirstNoTie() external {
        uint32 voters = 5;
        voteTime = new uint[](voters);
        // @FIXME rename to `system`
        InstantRunoffSystem memory data = InstantRunoffLibTestCases.noCycle5Voters(voteTime);
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
        AssertFirst({target: 0, expected: 3, time: 7, data: data});
        AssertFirst({target: 1, expected: 3, time: 3, data: data});
        AssertFirst({target: 2, expected: 3, time: 3, data: data});
        AssertEmpty(3, data);
        AssertFirst({target: 4, expected: 3, time: 5, data: data});
    }

    function testGetFirstCycleOf3() external {
        uint32 voters = 5;
        voteTime = new uint[](voters);
        InstantRunoffSystem memory data = InstantRunoffLibTestCases.cycle3VotersOf5Total(voteTime);
        //        -----<-
        //       /       \ 
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
        uint32[5] memory vote = [uint32(1), 2, 3, 1, 2];
        
        for (uint32 i = 0; i < voters; i++) {
            AssertFirst({
                target: i, 
                expected: vote[i],
                time: voteTime[i], 
                data: data
            });
        }
    }

    function testGetFirst2VerticesCycle() external {
        uint32 n = 3;
        uint32[] memory pi = new uint32[](n+1);
        for (uint32 i = 0; i < pi.length-1; i++) {
            pi.setAt(i, [int32(2), 2, 1][i]);
        }
        // 1 -> 2 <- 0
        //  \   /
        //   -<-

        voteTime = new uint[](n);
        for (uint256 i = 0; i < voteTime.length; i++) {
            voteTime[i] = i+1;
        }
        uint[] memory count = new uint[](n);
        uint maxCount = 0;
        for (uint256 i = 0; i < count.length; i++) {
            uint val = [0, 2, 2][i];
            count[i] = val;

            maxCount = Math.max(val, maxCount);
        }
        InstantRunoffSystemBuilder memory systemBuilder = InstantRunoffSystemBuilder({
            targetVotesAmount: maxCount,
            vote: pi,
            votesAmount: count
        });
        InstantRunoffSystem memory data = systemBuilder.buildFrom(voteTime);
        
        AssertFirst({target: 0, expected: 2, time: 1, data: data});
        AssertFirst({target: 1, expected: 2, time: 2, data: data});
        AssertFirst({target: 2, expected: 1, time: 3, data: data});
    }

    function testGetFirstInvalidInTheWayToMaxTied() external {
        uint32 n = 13;
        uint32[] memory pi = new uint32[](n+1);
        for (uint32 i = 0; i < pi.length-1; i++) {
            pi.setAt(i, [int32(2), 7, 12, 7, 8, 6, 4, 1, 10, 6, 11, 4, 10][i]);
        }
        // 10 <- 12 <- 2 <- 0
        // | \
        // |  11                     1 <-> 7 <- 3
        // ^   |
        // |   v
        // 8 <-4 <- 6 <- 9
        //           \
        //            -<- 5

        voteTime = new uint[](n);
        for (uint256 i = 0; i < voteTime.length; i++) {
            voteTime[i] = i+1;
        }
        uint[] memory count = new uint[](n);
        uint maxCount = 0;
        for (uint256 i = 0; i < count.length; i++) {
            uint val = [0, 2, 1, 0, 9, 0, 2, 2, 9, 0, 9, 9, 2][i];
            count[i] = val;

            maxCount = Math.max(val, maxCount);
        }
        InstantRunoffSystemBuilder memory systemBuilder = InstantRunoffSystemBuilder({
            targetVotesAmount: maxCount,
            vote: pi,
            votesAmount: count
        });
        InstantRunoffSystem memory data = systemBuilder.buildFrom(voteTime);
        
        AssertFirst({target: 0, expected: 10, time: 13, data: data});
        AssertEmpty(3, data);
        AssertEmpty(1, data);
        AssertFirst({target: 2, expected: 10, time: 13, data: data});
        AssertFirst({target: 4, expected: 8, time: 5, data: data});
        AssertFirst({target: 5, expected: 4, time: 7, data: data});
        AssertFirst({target: 6, expected: 4, time: 7, data: data});
        AssertEmpty(7, data);
        AssertFirst({target: 8, expected: 10, time: 9, data: data});
        AssertFirst({target: 9, expected: 4, time: 10, data: data});
        AssertFirst({target: 10, expected: 11, time: 11, data: data});
        AssertFirst({target: 11, expected: 4, time: 12, data: data});
        AssertFirst({target: 12, expected: 10, time: 13, data: data});
    }

    function AssertFirst(
        uint32 target, 
        uint32 expected, 
        uint time, 
        InstantRunoffSystem memory data
    ) 
        internal 
    {
        RepresentativeVote memory targetVote = data.getFirstInRank(target);
        Assert.isFalse(
            targetVote.none, 
            string.concat(
                "rank of ",
                Strings.toString(target),
                " is empty"
            )
        );
        Assert.equal(targetVote.choice, expected, "wrong first");
        Assert.equal(targetVote.time, time, "wrong time");
    }

    function testRemoveNoTie() external {
        uint32 voters = 5;
        voteTime = new uint[](voters);
        InstantRunoffSystem memory data = InstantRunoffLibTestCases.noCycle5Voters(voteTime);
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
        AssertFirst({target: 0, expected: 3, time: 7, data: data});
        AssertFirst({target: 1, expected: 3, time: 3, data: data});
        AssertFirst({target: 2, expected: 3, time: 3, data: data});
        AssertEmpty(3, data);
        AssertFirst({target: 4, expected: 3, time: 5, data: data});

        data.remove(TiedPerson.newData(3, voteTime[3]));

        AssertEmpty(0, data);
        AssertEmpty(1, data);
        AssertEmpty(2, data);
        AssertEmpty(4, data);
    }

    function testRemoveCycleOf3() external {
        uint32 n = 5;
        uint32[] memory pi = new uint32[](n+1);
        for (uint32 i = 0; i < pi.length-1; i++) {
            pi.setAt(i, [int32(1), 2, 3, 1, 2][i]);
        }
        //        -----<-
        //       /       \ 
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->

        voteTime = new uint[](n);
        for (uint256 i = 0; i < voteTime.length; i++) {
            voteTime[i] = [1, 4, 3, 2, 5][i];
        }
        uint[] memory count = new uint[](n);
        uint maxCount = 0;
        for (uint256 i = 0; i < count.length; i++) {
            uint val = [0, 4, 4, 4, 0][i];
            count[i] = val;

            maxCount = Math.max(val, maxCount);
        }
        InstantRunoffSystemBuilder memory systemBuilder = InstantRunoffSystemBuilder({
            targetVotesAmount: maxCount,
            vote: pi,
            votesAmount: count
        });
        InstantRunoffSystem memory data = systemBuilder.buildFrom(voteTime);
        
        for (uint32 i = 0; i < n; i++) {
            AssertFirst({
                target: i, 
                expected: uint32(pi.getAt(i)), 
                time: voteTime[i], 
                data: data
            });
        }

        data.remove(TiedPerson.newData(3, voteTime[3]));

        AssertFirst({target: 0, expected: 1, time: 1, data: data});
        AssertFirst({target: 1, expected: 2, time: 4, data: data});
        AssertFirst({target: 2, expected: 1, time: 3, data: data});
        AssertFirst({target: 4, expected: 2, time: 5, data: data});

        data.remove(TiedPerson.newData(2, voteTime[2]));

        AssertFirst({target: 0, expected: 1, time: 1, data: data});
        AssertEmpty(1, data);
        AssertEmpty(4, data);
    }

    function testFirstArrayAfterGetFirst() external {
        uint32 n = 5;
        uint32[] memory pi = new uint32[](n+1);
        for (uint32 i = 0; i < pi.length-1; i++) {
            pi.setAt(i, [int32(1), 2, 3, -1, 2][i]);
        }
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->

        voteTime = new uint[](n);
        for (uint256 i = 0; i < voteTime.length; i++) {
            voteTime[i] = [7, 2, 3, 0, 5][i];
        }
        uint[] memory count = new uint[](n);
        uint maxCount = 0;
        for (uint256 i = 0; i < count.length; i++) {
            uint val = [0, 1, 3, 4, 0][i];
            count[i] = val;

            maxCount = Math.max(val, maxCount);
        }
        InstantRunoffSystemBuilder memory systemBuilder = InstantRunoffSystemBuilder({
            targetVotesAmount: maxCount,
            vote: pi,
            votesAmount: count
        });
        InstantRunoffSystem memory data = systemBuilder.buildFrom(voteTime);
        
        AssertFirst({target: 0, expected: 3, time: 7, data: data});
        
        Assert.equal(data.firstInRank[1].choice, 3, "wrong value in `first` array");
        Assert.equal(data.firstInRank[2].choice, 3, "wrong value in `first` array");
        Assert.equal(data.firstInRank[4].choice, 2, "wrong value in `first` array");
    }

    function AssertEmpty(uint32 x, InstantRunoffSystem memory data) private {
        RepresentativeVote memory x1stVote = data.getFirstInRank(x);

        Assert.isTrue(
            x1stVote.none, 
            string.concat(
                Strings.toString(x), 
                " ranking is not empty. y = ",
                Strings.toString(x1stVote.choice),
                ", yTime = ",
                Strings.toString(x1stVote.time)
            )
        );
    }

    function testActiveVotersCycleOf3() external {
        uint32 voters = 5;                                             //        -----<-
        voteTime = new uint[](voters);                                 //       /       \ 
        InstantRunoffSystem memory system =                            // 0 -> 1 -> 2 -> 3
            InstantRunoffLibTestCases.cycle3VotersOf5Total(voteTime);  //          /
                                                                       //      4 ->
        system.remove(TiedPerson.newData(1, 0));
        AssertFirst(0, 2, 4, system);
        Assert.equal(system.activeVoters, 5, "wrong active voters amount");
        system.remove(TiedPerson.newData(2, 0));
        system.remove(TiedPerson.newData(3, 0));
        AssertEmpty(0, system);
        AssertEmpty(1, system);
        AssertEmpty(2, system);
        AssertEmpty(3, system);
        Assert.equal(system.activeVoters, 1, "wrong active voters amount");
        AssertEmpty(4, system);
        Assert.equal(system.activeVoters, 0, "wrong active voters amount");
    }

    function testActiveVotersInvalidInTheWayToMaxTied() external {
        uint32 voters = 13;
        voteTime = new uint[](voters);
        InstantRunoffSystem memory system = 
            InstantRunoffLibTestCases.twoCyclesTheLargestOf4Vertices13Total(voteTime);
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
        AssertEmpty(3, system);
        Assert.equal(system.activeVoters, 10, "wrong active voters amount");
    }
}

// @TODO refactor
// @TODO use functions from `InstantRunoffLibTestCases`