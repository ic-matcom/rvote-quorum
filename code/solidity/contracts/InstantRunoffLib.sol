// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.22 <0.9.0;

import "./TiedPerson.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./NegativeDefaultArray.sol";

struct RepresentativeVote {
    uint32 choice;
    uint time;
    bool none;
}

struct InstantRunoffSystem {
    /// @dev number of votes a person must has to be a valid person in rank
    uint targetVotesAmount;
    
    /// @dev not-removed union empty-rank people
    uint32 activeVoters;

    RepresentativeVote[] firstInRank;
    uint[] votesAmount;
    bool[] removed;
}

struct InstantRunoffSystemBuilder {
    uint targetVotesAmount;
    uint32[] vote;
    uint[] votesAmount;
}

library InstantRunoffLib {
    using InstantRunoffLib for InstantRunoffSystem;
    using NegativeDefaultArray for uint32[];
    using InstantRunoffLib for FirstInRankResolver;
    using InstantRunoffLib for InstantRunoffSystemBuilder;

    struct FirstInRankResolver {
        InstantRunoffSystem system;
        bool[] marked;
    }

    function buildFrom(InstantRunoffSystemBuilder memory self, uint[] storage voteTime) 
        internal 
        view 
        returns (InstantRunoffSystem memory newSystem) 
    {
        newSystem.targetVotesAmount = self.targetVotesAmount;
        uint32 allVoters = uint32(self.votesAmount.length);
        newSystem.activeVoters = allVoters;
        newSystem.firstInRank = self.getFirstInRankArray(voteTime);
        newSystem.votesAmount = self.votesAmount;
        newSystem.removed = new bool[](allVoters);
    }

    function getFirstInRankArray(
        InstantRunoffSystemBuilder memory self, 
        uint[] storage voteTime
    )
        internal
        view
        returns (RepresentativeVote[] memory firstInRank)
    {
        uint32 allVoters = uint32(self.votesAmount.length);
        firstInRank = new RepresentativeVote[](allVoters);

        for (uint32 voterId = 0; voterId < allVoters; voterId++) {  
            firstInRank[voterId] = self.buildVote(voterId, voteTime);
        }
    }

    function getFirstInRank(InstantRunoffSystem memory self, uint32 voter) 
        internal 
        pure 
        returns (RepresentativeVote memory) 
    {
        uint voters = self.firstInRank.length;
        FirstInRankResolver memory resolver = FirstInRankResolver({
            system: self,
            marked: new bool[](voters)
        });
        return resolver.getFirstInRank(voter);
    }

    function getFirstInRank(FirstInRankResolver memory self, uint32 voter) 
        internal 
        pure 
        returns (RepresentativeVote memory) 
    {
        self.marked[voter] = true;

        RepresentativeVote memory xFirstVote = self.system.firstInRank[voter];
        if (xFirstVote.none || self.marked[xFirstVote.choice]) {  
            // if `x`'s choice already marked then it's invalid and make `x`'s vote 
            // none is correct
            return makeVoteNone(xFirstVote);
        }
        if (self.isValid(xFirstVote.choice)) {
            return xFirstVote;
        } 
        return self.fromInvalidFirstVote(voter);
    }

    function remove(InstantRunoffSystem memory self, TiedPerson.Data memory voter) 
        internal 
        pure 
    {
        self.removed[voter.id] = true;
    }

    function isValid(FirstInRankResolver memory self, uint32 voter) 
        internal 
        pure 
        returns (bool) 
    {
        return self.system.votesAmount[voter] == self.system.targetVotesAmount 
            && !self.system.removed[voter];
    }

    function makeVoteNone(RepresentativeVote memory vote) 
        private 
        pure 
        returns (RepresentativeVote memory) 
    {
        vote.none = true;
        return vote;
    }

    function fromInvalidFirstVote(
        FirstInRankResolver memory self, 
        uint32 voter
    ) 
        internal 
        pure 
        returns (RepresentativeVote memory) 
    {
        RepresentativeVote memory firstVote = self.system.firstInRank[voter];
        RepresentativeVote memory first1stVote = self.getFirstInRank(firstVote.choice);

        if (first1stVote.none) {  // `xFirst`'s ranking is empty and `xFirst` is not valid
            return makeVoteNone(firstVote);
        }
        return self.updateFirstVote(voter, first1stVote);
    }

    function updateFirstVote(
        FirstInRankResolver memory self, 
        uint32 voter,
        RepresentativeVote memory voter1st1stVote 
    ) 
        internal 
        pure 
        returns (RepresentativeVote memory newFirstVote) 
    {
        RepresentativeVote memory xFirstVote = self.system.firstInRank[voter];
        newFirstVote.choice = voter1st1stVote.choice;
        newFirstVote.time = Math.max(voter1st1stVote.time, xFirstVote.time);
        self.system.setFirstInRankAt(voter, newFirstVote);
    }

    function buildVote(
        InstantRunoffSystemBuilder memory self, 
        uint32 voterId, 
        uint[] storage voteTime
    ) 
        internal 
        view 
        returns (RepresentativeVote memory newVote) 
    {
        if (self.voted(voterId)) {  
            newVote.choice = uint32(self.vote.getAt(voterId));
            newVote.time = voteTime[voterId];
        } else {
            newVote.none = true;
        }
    }

    function voted(InstantRunoffSystemBuilder memory self, uint32 voterId) 
        internal 
        pure 
        returns (bool) 
    {
        return self.vote.getAt(voterId) != DEFAULT_ELEMENT;
    }

    function setFirstInRankAt(
        InstantRunoffSystem memory self, 
        uint32 index, 
        RepresentativeVote memory value
    )
        internal
        pure
    {
        self.firstInRank[index] = value;
    }
}

// @TODO decrease `activeVoters` when a ranking gets empty