// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.22 <0.9.0;

import "../contracts/RepresentativeVoting.sol";

uint32 constant MAX_AMOUNT_OF_VOTERS = 13;

library RepresentativeVotingTestCases {
    function isSuccessExternalCallToVoteFor(RepresentativeVoting self, address chosenCandidate) 
        internal 
        returns (bool votingSuccess) 
    {
        (votingSuccess, ) = address(self).call(
            abi.encodeWithSelector(self.voteFor.selector, chosenCandidate)
        );
    }

    function notRegisteredAddressErrorWhenVotingFor(RepresentativeVoting self, address chosenCandidate)
        internal
        returns (bool notRegisteredAddressErrorRaised)
    {
        try self.voteFor(chosenCandidate) {
            notRegisteredAddressErrorRaised = false;
        } catch (bytes memory catchedLowLevelErrorData) {
            bytes4 expectedLowLevelErrorData = RepresentativeVoting.VoterAddressNotRegistered.selector;
            notRegisteredAddressErrorRaised = 
                expectedLowLevelErrorData == bytes4(catchedLowLevelErrorData);
        }
    }

    function notRegisteredIdErrorWhenVotingFor(RepresentativeVoting self, uint32 chosenCandidateId)
        internal
        returns (bool notRegisteredIdErrorRaised)
    {
        uint32 voterId = 0;
        try self.voteFromVoterIdToVoterId(voterId, chosenCandidateId) {
            notRegisteredIdErrorRaised = false;
        } catch (bytes memory catchedLowLevelErrorData) {
            bytes4 expectedLowLevelErrorData = RepresentativeVoting.VoterIdNotRegistered.selector;
            notRegisteredIdErrorRaised = 
                expectedLowLevelErrorData == bytes4(catchedLowLevelErrorData);
        }
    }

    function addressOfVoterId(uint32 voterId) internal view returns (address) {
        return allFakeAddresses()[voterId];
    }

    function buildRepresentativeVotingFromVotersAmount(uint32 votersAmount) 
        internal 
        returns (RepresentativeVoting voting) 
    {
        require(votersAmount <= MAX_AMOUNT_OF_VOTERS, "too many voters");

        address[] memory voterAddresses = new address[](votersAmount);
        for (uint32 voterId = 0; voterId < votersAmount; voterId++) {
            voterAddresses[voterId] = addressOfVoterId(voterId);
        }
        voting = new RepresentativeVoting(voterAddresses);
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

    function noCycle5Voters() internal returns (RepresentativeVoting voting) {
        voting = buildRepresentativeVotingFromVotersAmount(5);
        voting.voteFromVoterIdToVoterId(0, 1);  
        voting.voteFromVoterIdToVoterId(1, 2);
        voting.voteFromVoterIdToVoterId(2, 3);
        voting.voteFromVoterIdToVoterId(4, 2);
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
    }

    function cycle3VotersOf5Total() internal returns (RepresentativeVoting voting) {
        voting = buildRepresentativeVotingFromVotersAmount(5);
        voting.voteFromVoterIdToVoterId(3, 1);
        voting.voteFromVoterIdToVoterId(1, 2);
        voting.voteFromVoterIdToVoterId(0, 1);  
        voting.voteFromVoterIdToVoterId(4, 2);
        voting.voteFromVoterIdToVoterId(2, 3);
        //        -----<-
        //       /       \ 
        // 0 -> 1 -> 2 -> 3
        //          /
        //      4 ->
    }

    function branch5VotersOf6Total() internal returns (RepresentativeVoting voting) {
        voting = buildRepresentativeVotingFromVotersAmount(6);
        voting.voteFromVoterIdToVoterId(1, 2);
        voting.voteFromVoterIdToVoterId(2, 3);
        voting.voteFromVoterIdToVoterId(3, 4);
        voting.voteFromVoterIdToVoterId(4, 5);
        voting.voteFromVoterIdToVoterId(0, 4);
        // 1 -> 2 -> 3 -> 4 -> 5
        //               /
        //           0 ->
    }

    function cycle2VotersOf3Total() internal returns (RepresentativeVoting voting) {
        voting = buildRepresentativeVotingFromVotersAmount(3);
        voting.voteFromVoterIdToVoterId(1, 2);
        voting.voteFromVoterIdToVoterId(2, 1);
        voting.voteFromVoterIdToVoterId(0, 2);
        // 1 -> 2 <- 0
        //  \   /
        //   -<-
    }

    function twoCyclesTheLargestOf4Vertices13Total() internal returns (RepresentativeVoting voting) {
        voting = buildRepresentativeVotingFromVotersAmount(13);
        voting.voteFromVoterIdToVoterId(3, 7);
        voting.voteFromVoterIdToVoterId(12, 10);
        voting.voteFromVoterIdToVoterId(0, 2);
        voting.voteFromVoterIdToVoterId(11, 4);
        voting.voteFromVoterIdToVoterId(8, 10);
        voting.voteFromVoterIdToVoterId(9, 6);
        voting.voteFromVoterIdToVoterId(2, 12);
        voting.voteFromVoterIdToVoterId(5, 6);
        voting.voteFromVoterIdToVoterId(7, 1);
        voting.voteFromVoterIdToVoterId(10, 11);
        voting.voteFromVoterIdToVoterId(6, 4);
        voting.voteFromVoterIdToVoterId(4, 8);
        voting.voteFromVoterIdToVoterId(1, 7);
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
        returns (RepresentativeVoting voting) 
    {
        voting = buildRepresentativeVotingFromVotersAmount(13); //      1
        voting.voteFromVoterIdToVoterId(7, 1);    // (6) -> (7) -> (1)             (0)
        voting.voteFromVoterIdToVoterId(2, 8);    //     11   \     v  9
        voting.voteFromVoterIdToVoterId(8, 4);    //           -<- (3)
        voting.voteFromVoterIdToVoterId(3, 7);    //            4
        voting.voteFromVoterIdToVoterId(11, 12);  // (2) -> (8) -> (4) -> (5)
        voting.voteFromVoterIdToVoterId(9, 10);   //     2      3      7
        voting.voteFromVoterIdToVoterId(4, 5);    //       8
        voting.voteFromVoterIdToVoterId(12, 9);   //  (9) <- (12)
        voting.voteFromVoterIdToVoterId(1, 3);    // 6 v      ^   5
        voting.voteFromVoterIdToVoterId(10, 11);  // (10) -> (11)
        voting.voteFromVoterIdToVoterId(6, 7);    //      10
    }
}