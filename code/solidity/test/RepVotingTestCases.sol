// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.22 <0.9.0;

import "../contracts/RepVoting.sol";

library RepVotingTestCases {
    function noCycle5Voters() internal returns (RepVoting voting) {
        voting = new RepVoting(5);
        voting.vote(0, 1);  
        voting.vote(1, 2);
        voting.vote(2, 3);
        voting.vote(4, 2);
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
    }

    function cycle3VotersOf5Total() internal returns (RepVoting voting) {
        voting = new RepVoting(5);
        voting.vote(3, 1);
        voting.vote(1, 2);
        voting.vote(0, 1);  
        voting.vote(4, 2);
        voting.vote(2, 3);
        //        -----<-
        //       /       \ 
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
    }

    function branch5VotersOf6Total() internal returns (RepVoting voting) {
        voting = new RepVoting(6);
        voting.vote(1, 2);
        voting.vote(2, 3);
        voting.vote(3, 4);
        voting.vote(4, 5);
        voting.vote(0, 4);
        // 1 -> 2 -> 3 -> 4 -> 5
        //               /
        //           0 ->
    }

    function cycle2VotersOf3Total() internal returns (RepVoting voting) {
        voting = new RepVoting(3);
        voting.vote(1, 2);
        voting.vote(2, 1);
        voting.vote(0, 2);
        // 1 -> 2 <- 0
        //  \   /
        //   -<-
    }

    function twoCyclesTheLargestOf4Vertices13Total() internal returns (RepVoting voting) {
        voting = new RepVoting(13);
        voting.vote(3, 7);
        voting.vote(12, 10);
        voting.vote(0, 2);
        voting.vote(11, 4);
        voting.vote(8, 10);
        voting.vote(9, 6);
        voting.vote(2, 12);
        voting.vote(5, 6);
        voting.vote(7, 1);
        voting.vote(10, 11);
        voting.vote(6, 4);
        voting.vote(4, 8);
        voting.vote(1, 7);
        // 10 <- 12 <- 2 <- 0
        // | \
        // |  11                     1 <-> 7 <- 3
        // ^   |
        // |   v
        // 8 <-4 <- 6 <- 9
        //           \
        //            -<- 5
    }

    function eightMaxTiedPersons2CyclesOneChain13Total() 
        internal 
        returns (RepVoting voting) 
    {
        voting = new RepVoting(13); //      1
        voting.vote(7, 1);    // (6) -> (7) -> (1)             (0)
        voting.vote(2, 8);    //     11   \     v  9
        voting.vote(8, 4);    //           -<- (3)
        voting.vote(3, 7);    //            4
        voting.vote(11, 12);  // (2) -> (8) -> (4) -> (5)
        voting.vote(9, 10);   //     2      3      7
        voting.vote(4, 5);    //       8
        voting.vote(12, 9);   //  (9) <- (12)
        voting.vote(1, 3);    // 6 v      ^   5
        voting.vote(10, 11);  // (10) -> (11)
        voting.vote(6, 7);    //      10
    }
}