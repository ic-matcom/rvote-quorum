// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.25 <0.9.0;

import "truffle/Assert.sol";
import "../contracts/Ranks.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract TestRanks {
    using Ranks for Ranks.Data;

    function testGetFirstNoTie() external {
        uint32 n = 5;
        uint32[] memory pi = new uint32[](n+1);
        for (uint32 i = 0; i < pi.length-1; i++) {
            set(pi, i, [int32(1), 2, 3, -1, 2][i]);
        }
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->

        uint[] memory voteTime = new uint[](n);
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
        Ranks.Data memory data = Ranks.build(maxCount, n, pi, voteTime, count);
        
        AssertFirst({target: 0, expected: 3, time: 7, data: data});
        AssertFirst({target: 1, expected: 3, time: 3, data: data});
        AssertFirst({target: 2, expected: 3, time: 3, data: data});
        AssertEmpty(3, data);
        AssertFirst({target: 4, expected: 3, time: 5, data: data});
    }

    function testGetFirstCycleOf3() external {
        uint32 n = 5;
        uint32[] memory pi = new uint32[](n+1);
        for (uint32 i = 0; i < pi.length-1; i++) {
            set(pi, i, [int32(1), 2, 3, 1, 2][i]);
        }
        //        -----<-
        //       /       \ 
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->

        uint[] memory voteTime = new uint[](n);
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
        Ranks.Data memory data = Ranks.build(maxCount, n, pi, voteTime, count);
        
        for (uint32 i = 0; i < n; i++) {
            AssertFirst({
                target: i, 
                expected: uint32(get(pi, i)), 
                time: voteTime[i], 
                data: data
            });
        }
    }

    function testGetFirstInvalidInTheWayToMaxTied() external {
        uint32 n = 13;
        uint32[] memory pi = new uint32[](n+1);
        for (uint32 i = 0; i < pi.length-1; i++) {
            set(pi, i, [int32(2), 7, 12, 7, 8, 6, 4, 1, 10, 6, 11, 4, 10][i]);
        }
        // 10 <- 12 <- 2 <- 0
        // | \
        // |  11                     1 <-> 7 <- 3
        // ^   |
        // |   v
        // 8 <-4 <- 6 <- 9
        //           \
        //            -<- 5

        uint[] memory voteTime = new uint[](n);
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
        Ranks.Data memory data = Ranks.build(maxCount, n, pi, voteTime, count);
        
        AssertFirst({target: 0, expected: 10, time: 13, data: data});
        AssertEmpty(1, data);
        AssertFirst({target: 2, expected: 10, time: 13, data: data});
        AssertEmpty(3, data);
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
        Ranks.Data memory data
    ) 
        internal 
    {
        (uint32 got, uint gotTime, bool empty) = data.getFirst(target);
        Assert.isFalse(
            empty, 
            string.concat(
                "rank of ",
                Strings.toString(target),
                " is empty"
            )
        );
        Assert.equal(got, expected, "wrong first");
        Assert.equal(gotTime, time, "wrong time");
    }

    function testRemoveNoTie() external {
        uint32 n = 5;
        uint32[] memory pi = new uint32[](n+1);
        for (uint32 i = 0; i < pi.length-1; i++) {
            set(pi, i, [int32(1), 2, 3, -1, 2][i]);
        }
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->

        uint[] memory voteTime = new uint[](n);
        for (uint256 i = 0; i < voteTime.length; i++) {
            voteTime[i] = [1, 2, 3, 0, 5][i];
        }
        uint[] memory count = new uint[](n);
        uint maxCount = 0;
        for (uint256 i = 0; i < count.length; i++) {
            uint val = [0, 1, 3, 4, 0][i];
            count[i] = val;

            maxCount = Math.max(val, maxCount);
        }
        Ranks.Data memory data = Ranks.build(maxCount, n, pi, voteTime, count);
        
        AssertFirst({target: 0, expected: 3, time: 3, data: data});
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
            set(pi, i, [int32(1), 2, 3, 1, 2][i]);
        }
        //        -----<-
        //       /       \ 
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->

        uint[] memory voteTime = new uint[](n);
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
        Ranks.Data memory data = Ranks.build(maxCount, n, pi, voteTime, count);
        
        for (uint32 i = 0; i < n; i++) {
            AssertFirst({
                target: i, 
                expected: uint32(get(pi, i)), 
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
            set(pi, i, [int32(1), 2, 3, -1, 2][i]);
        }
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->

        uint[] memory voteTime = new uint[](n);
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
        Ranks.Data memory data = Ranks.build(maxCount, n, pi, voteTime, count);
        
        AssertFirst({target: 0, expected: 3, time: 7, data: data});
        
        Assert.equal(data.first[1].choice, 3, "wrong value in `first` array");
        Assert.equal(data.first[2].choice, 3, "wrong value in `first` array");
        Assert.equal(data.first[4].choice, 2, "wrong value in `first` array");
    }

    function AssertEmpty(uint32 x, Ranks.Data memory data) private {
        (uint32 y, uint yTime, bool yEmpty) = data.getFirst(x);

        Assert.isTrue(
            yEmpty, 
            string.concat(
                Strings.toString(x), 
                " ranking is not empty. y = ",
                Strings.toString(y),
                ", yTime = ",
                Strings.toString(yTime)
            )
        );
    }

    // @TODO move this function to a library and import that library in RepVoting
    /// @dev Sets parent of a vertex
    /// @param pi DFS parent array
    /// @param x Target vertex
    /// @param y Parent vertex
    function set(uint32[] memory pi, uint32 x, int32 y) private pure {
        pi[x+1] = uint32(y+1);
    }

    // @TODO move this function to a library and import that library in RepVoting
    /// @dev pi[x+1]-1 = parent of x. This function encapsulates that computation so developer
    /// hasn't to worry about adding and substracting 1
    /// @return Parent of x
    function get(uint32[] memory pi, uint32 x) private pure returns (int32) {
        return int32(pi[x+1])-1;
    }
}