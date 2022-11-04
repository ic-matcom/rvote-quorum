// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.22 <0.9.0;

import './TiedPerson.sol';
import "@openzeppelin/contracts/utils/math/Math.sol";

library Ranks {
    using Ranks for Data;

    struct IrvVote {
        uint32 choice;
        uint time;
        bool none;
    }

    struct Data {
        /// @dev number of votes a person must has to be a valid person in rank
        uint targetCount;
        
        /// @dev not-removed union empty-rank people
        uint32 activeAmount;

        IrvVote[] first;
        uint[] count;
        bool[] removed;
    }

    function build(
        uint targetCount, 
        uint32 ranksAmount, 
        uint32[] memory pi,
        uint[] memory voteTime,
        uint[] memory count
    ) 
        internal 
        pure 
        returns (Data memory ans) 
    {
        ans.targetCount = targetCount;
        ans.activeAmount = ranksAmount;
        ans.first = new IrvVote[](ranksAmount);
        ans.count = count;
        ans.removed = new bool[](ranksAmount);

        for (uint32 x = 0; x < ranksAmount; x++) {  // filling `first` values from `pi`
            IrvVote memory vote = ans.first[x];
            int32 y = get(pi, x);

            if (y != -1) {  // @TODO move -1 to a constant in `pi` library and use it instead
                vote.choice = uint32(y);
                vote.time = voteTime[x];
            } else {
                vote.none = true;
            }
        }
    }

    /// @dev Gets first max-tied person in `x`'s ranking and the time its predecessor 
    /// (can be a non max-tied) in the ranking voted for him. If `x`'s ranking is empty,
    /// `emptyRank` is set to true.
    /// @param x The id of the voter
    /// @return firstChoice The id of the first max-tied person in `x`'s ranking
    /// @return oldestVoteTime The time the predecessor of `firstChoice` in `x`'s ranking
    /// voted for him
    /// @return emptyRank Whether `x`'s ranking is empty
    function getFirst(Data memory self, uint32 x) 
        internal 
        pure 
        returns (uint32 firstChoice, uint oldestVoteTime, bool emptyRank) 
    {
        uint n = self.first.length;
        return getFirst_(x, self, new bool[](n));
    }

    function getFirst_(uint32 x, Data memory data, bool[] memory mark) 
        private 
        pure 
        returns (uint32 firstChoice, uint oldestVoteTime, bool emptyRank) 
    {
        mark[x] = true;

        IrvVote memory xVote = data.first[x];
        uint32 y = xVote.choice;

        if (xVote.none || mark[y]) {  // `x` didn't vote or `y` already visited
            xVote.none = true;  // in case `!xVote.none`
            return (0, 0, true);
        }
        oldestVoteTime = xVote.time;

        if (isValid(y, data)) {
            firstChoice = y;
        } else {
            (uint32 yy, uint yyTime, bool yyEmpty) = getFirst_(y, data, mark);

            if (yyEmpty) {  // `y`'s ranking is empty and `y` is not valid
                xVote.none = true;
                return (0, 0, true);  // ergo, `x`'s ranking is empty
            }
            firstChoice = yy;
            oldestVoteTime = Math.max(yyTime, oldestVoteTime);

            data.first[x] = IrvVote({choice: firstChoice, time: oldestVoteTime, none: false});
        }
    }

    function remove(Data memory self, TiedPerson.Data memory target) internal pure {
        self.removed[target.id] = true;
    }

    function isValid(uint32 x, Data memory data) private pure returns (bool) {
        return data.count[x] == data.targetCount && !data.removed[x];
    }

    // @TODO move this function to a library and import that library in RepVoting
    // @FIXME `y` param must be `int32` instead in order to support -1
    /// @dev Sets parent of a vertex
    /// @param pi DFS parent array
    /// @param x Target vertex
    /// @param y Parent vertex
    function set(uint32[] memory pi, uint32 x, uint32 y) private pure {
        pi[x+1] = y+1;
    }

    // @TODO move this function to a library and import that library in RepVoting
    /// @dev pi[x+1]-1 = parent of x. This function encapsulates that computation so developer
    /// hasn't to worry about adding and substracting 1
    /// @return Parent of x
    function get(uint32[] memory pi, uint32 x) private pure returns (int32) {
        return int32(pi[x+1])-1;
    }
}