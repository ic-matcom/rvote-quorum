// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.25 <0.9.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/RepVoting.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TestRepVoting {
    function testVote() external {
        RepVoting voting = new RepVoting(5);
        voting.vote(0, 1);  
        voting.vote(1, 2);
        voting.vote(2, 3);
        voting.vote(4, 2);
    }

    function testNoCycleVoting() external {
        RepVoting voting = new RepVoting(5);
        voting.vote(0, 1);  
        voting.vote(1, 2);
        voting.vote(2, 3);
        voting.vote(4, 2);

        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
        uint[5] memory data = [uint(0), 1, 3, 4, 0];
        uint[] memory expected = new uint[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            expected[i] = data[i];
        }

        uint[] memory got = voting.countVotes();

        Assert.equal(
            got, 
            expected, 
            string.concat("wrong counting. Expected: ", toString(expected), ", got: ", toString(got))
        );
    }

    function toString(uint[] memory data) private pure returns (string memory) {
        string memory str = '[';
        for (uint256 i = 0; i < data.length; i++) {
            str = string.concat(str, Strings.toString(data[i]), ', ');
        }
        str = string.concat(str, ']');
        return str;
    }

    function testSimpleCycleVoting() external {
        RepVoting voting = new RepVoting(5);
        voting.vote(0, 1);  
        voting.vote(1, 2);
        voting.vote(2, 3);
        voting.vote(4, 2);
        voting.vote(3, 1);

        //        -----<-
        //       /       \ 
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
        uint[5] memory data = [uint(0), 4, 4, 4, 0];
        uint[] memory expected = new uint[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            expected[i] = data[i];
        }
        uint[] memory got = voting.countVotes();

        Assert.equal(
            got, 
            expected, 
            string.concat("wrong counting. Expected: ", toString(expected), ", got: ", toString(got))
        );
    }

    function testLongBranch() external {
        RepVoting voting = new RepVoting(6);
        voting.vote(1, 2);
        voting.vote(2, 3);
        voting.vote(3, 4);
        voting.vote(4, 5);
        voting.vote(0, 4);

        // 1 -> 2 -> 3 -> 4 -> 5
        //               /
        //           0 ->
        uint[6] memory data = [uint(0), 0, 1, 2, 4, 5];
        uint[] memory expected = new uint[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            expected[i] = data[i];
        }
        uint[] memory got = voting.countVotes();

        Assert.equal(
            got, 
            expected, 
            string.concat("wrong counting. Expected: ", toString(expected), ", got: ", toString(got))
        );
    }

    function test2VerticesCycle() external {
        RepVoting voting = new RepVoting(3);
        voting.vote(1, 2);
        voting.vote(2, 1);
        voting.vote(0, 2);

        // 1 -> 2 <- 0
        //  \   /
        //   -<-
        uint[3] memory data = [uint(0), 2, 2];
        uint[] memory expected = new uint[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            expected[i] = data[i];
        }
        uint[] memory got = voting.countVotes();

        Assert.equal(
            got, 
            expected, 
            string.concat("wrong counting. Expected: ", toString(expected), ", got: ", toString(got))
        );
    }

    function test2Cycles() external {
        RepVoting voting = new RepVoting(13);
        voting.vote(0, 2);
        voting.vote(2, 12);
        voting.vote(12, 10);
        voting.vote(10, 11);
        voting.vote(11, 4);
        voting.vote(4, 8);
        voting.vote(8, 10);
        voting.vote(6, 4);
        voting.vote(9, 6);
        voting.vote(5, 6);
        voting.vote(3, 7);
        voting.vote(7, 1);
        voting.vote(1, 7);

        // 10 <- 12 <- 2 <- 0
        // | \
        // |  11                     1 <-> 7 <- 3
        // ^   |
        // |   v
        // 8 <-4 <- 6 <- 9
        //           \
        //            -<- 5

        //                            0  1  2  3  4  5  6  7  8  9 10 11 12
        uint[13] memory data = [uint(0), 2, 1, 0, 9, 0, 2, 2, 9, 0, 9, 9, 2];
        uint[] memory expected = new uint[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            expected[i] = data[i];
        }
        uint[] memory got = voting.countVotes();

        Assert.equal(
            got, 
            expected, 
            string.concat("wrong counting. Expected: ", toString(expected), ", got: ", toString(got))
        );
    }

    function testCountVotesTwice() external {
        RepVoting voting = new RepVoting(3);
        voting.vote(1, 2);
        voting.vote(2, 1);
        voting.vote(0, 2);

        // 1 -> 2 <- 0
        //  \   /
        //   -<-
        uint[3] memory data = [uint(0), 2, 2];
        uint[] memory expected = new uint[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            expected[i] = data[i];
        }

        uint[] memory got = voting.countVotes();
        Assert.equal(
            got, 
            expected, 
            string.concat(
                "wrong counting. Expected: ", 
                toString(expected), 
                ", got: ", 
                toString(got))
        );

        got = voting.countVotes();
        Assert.equal(
            got, 
            expected, 
            string.concat(
                "wrong counting. Expected: ", 
                toString(expected), 
                ", got: ", 
                toString(got))
        );
    }
}
