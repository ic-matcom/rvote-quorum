// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.22 <0.9.0;

import "../contracts/RepVoting.sol";

uint32 constant MAX_AMOUNT_OF_VOTERS = 13;

library RepVotingTestCases {
    function isSuccessExternalCallToVoteFor(RepVoting self, address chosenCandidate) 
        internal 
        returns (bool votingSuccess) 
    {
        (votingSuccess, ) = address(self).call(
            abi.encodeWithSelector(self.voteFor.selector, chosenCandidate)
        );
    }

    function notRegisteredAddressErrorWhenVotingFor(RepVoting self, address chosenCandidate)
        internal
        returns (bool notRegisteredAddressErrorRaised)
    {
        try self.voteFor(chosenCandidate) {
            notRegisteredAddressErrorRaised = false;
        } catch (bytes memory catchedLowLevelErrorData) {
            bytes4 expectedLowLevelErrorData = RepVoting.VoterAddressNotRegistered.selector;
            notRegisteredAddressErrorRaised = 
                expectedLowLevelErrorData == bytes4(catchedLowLevelErrorData);
        }
    }

    function notRegisteredIdErrorWhenVotingFor(RepVoting self, uint32 chosenCandidateId)
        internal
        returns (bool notRegisteredIdErrorRaised)
    {
        uint32 voterId = 0;
        try self.vote(voterId, chosenCandidateId) {
            notRegisteredIdErrorRaised = false;
        } catch (bytes memory catchedLowLevelErrorData) {
            bytes4 expectedLowLevelErrorData = RepVoting.VoterIdNotRegistered.selector;
            notRegisteredIdErrorRaised = 
                expectedLowLevelErrorData == bytes4(catchedLowLevelErrorData);
        }
    }

    function addressOfVoterId(uint32 voterId) internal view returns (address) {
        return allFakeAddresses()[voterId];
    }

    function buildRepVotingFromVotersAmount(uint32 votersAmount) 
        internal 
        returns (RepVoting voting) 
    {
        require(votersAmount <= MAX_AMOUNT_OF_VOTERS, "too many voters");

        address[] memory voterAddresses = new address[](votersAmount);
        for (uint32 voterId = 0; voterId < votersAmount; voterId++) {
            voterAddresses[voterId] = addressOfVoterId(voterId);
        }
        voting = new RepVoting(voterAddresses);
    }

    function allFakeAddresses() private view returns (address[13] memory) {
        address[13] memory addresses = [
            address(this),
            0xd6f3196B17C84CCac9F1dAA14DA7a80e80D6dDBa,
            0x038Bb18A04cFfef4D5773dF647667F5d0F655904,
            0xceB51173c578b5118C1C8bDd7624b25c8678cEa2,
            0xf0C2B10db15273fD19C5a2368fa0ec36865470C6,
            0x8108755cCF4CCb2e63e32C0E21176b6d4819754F,
            0x9fe91d72A9167506e2f6AFa0bDb642C0DC35E284,
            0x38993baabF63B45b5df83E6d5652b5DA578b3959,
            0x96BD26FF872a4ED263cF9389dF61E22b51B7016c,
            0xa3D187a9A15Cbf3a22b0f355A30345A4EBB57ECe,
            0x211f56De56047696721E573540E02d13a5c22f43,
            0xC228EcC721a67E9561018f5EF4069ef1C2a23B73,
            0xE637D780f44C72CB170934008F9dbeD656Fcb351
        ];
        assert(addresses.length == MAX_AMOUNT_OF_VOTERS);
        return addresses;
    }

    function noCycle5Voters() internal returns (RepVoting voting) {
        voting = buildRepVotingFromVotersAmount(5);
        voting.vote(0, 1);  
        voting.vote(1, 2);
        voting.vote(2, 3);
        voting.vote(4, 2);
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
    }

    function cycle3VotersOf5Total() internal returns (RepVoting voting) {
        voting = buildRepVotingFromVotersAmount(5);
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
        voting = buildRepVotingFromVotersAmount(6);
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
        voting = buildRepVotingFromVotersAmount(3);
        voting.vote(1, 2);
        voting.vote(2, 1);
        voting.vote(0, 2);
        // 1 -> 2 <- 0
        //  \   /
        //   -<-
    }

    function twoCyclesTheLargestOf4Vertices13Total() internal returns (RepVoting voting) {
        voting = buildRepVotingFromVotersAmount(13);
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
        voting = buildRepVotingFromVotersAmount(13); //      1
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