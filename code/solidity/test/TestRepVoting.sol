// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.25 <0.9.0;

import "truffle/Assert.sol";
import "../contracts/RepVoting.sol";
import "./Array.sol";
import "./RepVotingTestCases.sol";

contract TestRepVoting {
    using RepVotingTestCases for RepVoting;

    function testVote() external {
        RepVotingTestCases.noCycle5Voters();
    }

    function testNoCycleVoting() external {
        RepVoting voting = RepVotingTestCases.noCycle5Voters();
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
        uint[] memory expected = Array.fromStaticArray([uint(0), 1, 3, 4, 0]);
        uint[] memory got = voting.countVotes();

        Assert.equal(
            got, 
            expected, 
            string.concat(
                "wrong counting. Expected: ", 
                Array.toString(expected), 
                ", got: ", 
                Array.toString(got)
            )
        );
    }

    function testSimpleCycleVoting() external {
        RepVoting voting = RepVotingTestCases.cycle3VotersOf5Total();
        //        -----<-
        //       /       \ 
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
        uint[] memory expected = Array.fromStaticArray([uint(0), 4, 4, 4, 0]);
        uint[] memory got = voting.countVotes();

        Assert.equal(
            got, 
            expected, 
            string.concat(
                "wrong counting. Expected: ", 
                Array.toString(expected), 
                ", got: ", 
                Array.toString(got)
            )
        );
    }

    function testLongBranch() external {
        RepVoting voting = RepVotingTestCases.branch5VotersOf6Total();
        // 1 -> 2 -> 3 -> 4 -> 5
        //               /
        //           0 ->
        uint[] memory expected = Array.fromStaticArray([uint(0), 0, 1, 2, 4, 5]);
        uint[] memory got = voting.countVotes();

        Assert.equal(
            got, 
            expected, 
            string.concat(
                "wrong counting. Expected: ", 
                Array.toString(expected), 
                ", got: ", 
                Array.toString(got)
            )
        );
    }

    function test2VerticesCycle() external {
        RepVoting voting = RepVotingTestCases.cycle2VotersOf3Total();
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
                Array.toString(expected), 
                ", got: ", 
                Array.toString(got)
            )
        );
    }

    function test2Cycles() external {
        RepVoting voting = RepVotingTestCases.twoCyclesTheLargestOf4Vertices13Total();
        uint[] memory expected = Array.fromStaticArray(
            [uint(0), 2, 1, 0, 9, 0, 2, 2, 9, 0, 9, 9, 2]
        );
        uint[] memory got = voting.countVotes();

        Assert.equal(
            got, 
            expected, 
            string.concat(
                "wrong counting. Expected: ", 
                Array.toString(expected), 
                ", got: ", 
                Array.toString(got)
            )
        );
    }

    function testCountVotesTwice() external {
        RepVoting voting = RepVotingTestCases.cycle2VotersOf3Total();
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
                Array.toString(expected), 
                ", got: ", 
                Array.toString(got))
        );

        got = voting.countVotes();
        Assert.equal(
            got, 
            expected, 
            string.concat(
                "wrong counting. Expected: ", 
                Array.toString(expected), 
                ", got: ", 
                Array.toString(got))
        );
    }

    function testGetWinnerIdNoTie() external {
        RepVoting voting = RepVotingTestCases.noCycle5Voters();
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
        Assert.equal(voting.getWinnerId(), 3, "wrong winner");
    }

    function testGetWinnerIdSimpleCycle() external {
        RepVoting voting = RepVotingTestCases.cycle3VotersOf5Total();
        //        -----<-
        //       /       \ 
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
        Assert.equal(voting.getWinnerId(), 1, "wrong winner");
    }

    function testGetWinnerId2VerticesCycle() external {
        RepVoting voting = RepVotingTestCases.cycle2VotersOf3Total();
        // 1 -> 2 <- 0
        //  \   /
        //   -<-
        Assert.equal(voting.getWinnerId(), 2, "wrong winner");
    }

    function testGetWinnerId2Cycles() external {
        RepVoting voting = RepVotingTestCases.twoCyclesTheLargestOf4Vertices13Total();
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
        Assert.equal(voting.getWinnerId(), 4, "wrong winner");
    }

    function testCountEightMaxTiedPersons2CyclesOneChain13Total() external {
        RepVoting voting = RepVotingTestCases.eightMaxTiedPersons2CyclesOneChain13Total();
        uint[] memory expected = Array.fromStaticArray(
            [uint(0), 3, 0, 3, 2, 3, 0, 3, 1, 3, 3, 3, 3]
        );
        uint[] memory got = voting.countVotes();
        Assert.equal(
            got, 
            expected, 
            string.concat(
                "wrong counting. Expected: ", 
                Array.toString(expected), 
                ", got: ", 
                Array.toString(got)
            )
        );
    }

    function testGetWinnerIdEightMaxTiedPersons2CyclesOneChain13Total() external {
        RepVoting voting = RepVotingTestCases.eightMaxTiedPersons2CyclesOneChain13Total();
        Assert.equal(voting.getWinnerId(), 5, "wrong winner");
    }

    function testVoteFromRegisteredAddress() external {
        RepVoting votingSystem = RepVotingTestCases.buildRepVotingFromVotersAmount(3);

        uint32 chosenCandidateId = 1;
        bool votingSuccess = votingSystem.isSuccessExternalCallToVoteFor(
            RepVotingTestCases.addressOfVoterId(chosenCandidateId)
        );
        Assert.isTrue(votingSuccess, "voting should be successful");
        Assert.equal(votingSystem.getWinnerId(), chosenCandidateId, "wrong winner");
    }

    function testNotRegisteredVoterAddress() external {
        RepVoting votingSystem = RepVotingTestCases.buildRepVotingFromVotersAmount(5);
        address notRegisteredAddress = 0x1dbd0dA6F4fA97942A8f1159a946909Cd23A2BC8;
        Assert.isTrue(
            votingSystem.notRegisteredAddressErrorWhenVotingFor(notRegisteredAddress), 
            "not registered address error should be raised"
        );
    }

    function testNotRegisteredVoterId() external {
        uint32 totalVoters = 5;
        RepVoting votingSystem = RepVotingTestCases.buildRepVotingFromVotersAmount(totalVoters);
        uint32 notRegisteredVoterId = totalVoters;  // voters IDs go from 0 to `totalVoters-1` 
        Assert.isTrue(
            votingSystem.notRegisteredIdErrorWhenVotingFor(notRegisteredVoterId), 
            "not registered voter ID error should be raised"
        );
    }
}
// @TODO reemplaza la parte donde se setea el grafo x la funcio'n correspondiente de
// RepVotingTestCases