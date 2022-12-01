// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

/// @author Andy Ledesma García
/// @dev Info about a person tied in the first place of a representative voting counting
library TiedPerson {
    struct Data {
        uint32 id;
        uint oldestVoteTime;
        
        /// @dev Used to check if the instance is the default value. It's set to true in
        /// the `newData()` function. It's used in the `inArray()` function 
        bool nonDefault;

        /// @dev Number of votes received by this person in the Instant Runoff
        uint votes;
    }

    event TiedPersonLog(Data person);

    function log(Data memory person) internal {
        emit TiedPersonLog(person);
    }
    
    /// @dev Should be taken as the constructor of the `Data` struct
    /// @param voteTime The time of the first vote received by this person
    // @FIXME rename to `build` or similar so consistency is achieved
    // @FIXME rename `ans` to `newData` or similar
    function newData(uint32 id, uint voteTime) internal pure returns (Data memory ans) {
        ans.id = id;
        ans.oldestVoteTime = voteTime;
        ans.nonDefault = true;
        ans.votes = 1;
    }

    /// @dev Checks if the `Data` instance at index `id` in the array `self` is the default value.
    /// This allows taking `self` as an in-memory `mapping(uint32 => Data)`
    function defaultAt(Data[] memory self, uint32 id) internal pure returns (bool) {
        return !self[id].nonDefault;
    }

    function addVote(Data memory self, uint voteTime) internal pure {
        if (self.oldestVoteTime < voteTime) {
            self.oldestVoteTime = voteTime;
        }
        self.votes++;
    }
}

// @TODO check all references are sorrounded by ``