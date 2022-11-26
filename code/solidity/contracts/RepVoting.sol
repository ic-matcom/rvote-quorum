// SPDX-License-Identifier: UNLICENSED
// @audit NOTE check if 'UNLICENSED' is suitable. See repo license.
pragma solidity >=0.4.22 <0.9.0;

import "./TiedPerson.sol";
import "./TiedPersonHeap.sol";
import "./InstantRunoffLib.sol";
import "./NegativeDefaultArray.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title Representative voting system
/// @author Andy Ledesma García
contract RepVoting {  // @FIXME rename to `RepresentativeVoting`
    using TiedPerson for TiedPerson.Data;
    using InstantRunoffLib for InstantRunoffSystem;
    using InstantRunoffLib for InstantRunoffSystemBuilder;
    using {TiedPerson.defaultAt} for TiedPerson.Data[];
    using TiedPersonHeap for TiedPersonHeap.Data;
    using NegativeDefaultArray for uint32[];

    /// @dev (x, y) is an arc of graph <=> y voted for x
    uint32[][] graph;
    bool[] voted;
    uint[] voteTime;
    uint time;
    mapping(address => VoterId) addressToVoterId;
    address[] voterIdToAddress;
    uint32 registeredVoters;
    address owner;

    struct VoterId {
        uint32 value;
        bool registered;
    }

    error VoterAddressNotRegistered(address voterAddress);
    error VoterIdNotRegistered(uint32 voterId);
    // @TODO make error for double voting and test it in solidity

    constructor(address[] memory voters) {
        uint votersAmount = voters.length;
        require(votersAmount > 0, "at least one voter must be registered");

        initializeStateVariablesFromVotersAmount(votersAmount);
        owner = msg.sender;

        for (uint i = 0; i < votersAmount; i++) {
            registerVoterAddress(voters[i]);
        }
    }

    function initializeStateVariablesFromVotersAmount(uint votersAmount) private {
        graph = new uint32[][](votersAmount);
        voted = new bool[](votersAmount);
        voteTime = new uint[](votersAmount);
    }

    function registerVoterAddress(address voterAddress) private {  
        require(!isVoterAddressRegistered(voterAddress), "already registered");
        addressToVoterId[voterAddress] = VoterId({value: registeredVoters++, registered: true});
        voterIdToAddress.push(voterAddress);
    }
    
    function isVoterAddressRegistered(address voter) private view returns (bool) {
        return addressToVoterId[voter].registered;
    }
    
    function isVoterIdRegistered(uint32 voterId) private view returns (bool) {
        return voterId < registeredVoters;
    }

    modifier onlyIfVoterAddressRegistered(address voterAddress) {
        if (!isVoterAddressRegistered(voterAddress)) {
            revert VoterAddressNotRegistered(voterAddress);
        }
        _;
    }

    modifier onlyIfVoterIdRegistered(uint32 voterId) {
        if (!isVoterIdRegistered(voterId)) {
            revert VoterIdNotRegistered(voterId);
        }
        _;
    }

    modifier onlyIfSenderIsOwner() {
        require(msg.sender == owner, "only owner can call this function");
        _;
    }

    function voteFor(address chosenCandidate) 
        external 
        onlyIfVoterAddressRegistered(msg.sender)
        onlyIfVoterAddressRegistered(chosenCandidate)
    {
        address voter = msg.sender;
        uint32 voterId = getVoterIdFromAddress(voter);
        uint32 chosenCandidateId = getVoterIdFromAddress(chosenCandidate);
        voteFromVoterIdToVoterId_(voterId, chosenCandidateId);
    }

    function getVoterIdFromAddress(address voterAddress) private view returns (uint32) {
        return addressToVoterId[voterAddress].value;
    }

    function voteFromVoterIdToVoterId(uint32 voterId, uint32 chosenCandidateId) 
        external 
        onlyIfSenderIsOwner
    {
        voteFromVoterIdToVoterId_(voterId, chosenCandidateId);
    }

    function voteFromVoterIdToVoterId_(uint32 voterId, uint32 chosenCandidateId) 
        private
        onlyIfVoterIdRegistered(voterId)
        onlyIfVoterIdRegistered(chosenCandidateId)
    {
        require(
            !voted[voterId], 
            string.concat("voter with ID ", Strings.toString(voterId), " already voted")
        );

        graph[chosenCandidateId].push(voterId);
        voted[voterId] = true;
        voteTime[voterId] = ++time;
    }

    enum DfsColor { White, Gray, Black }

    /// Count the votes received by each participant
    /// @return count Votes received by each participant
    function countVotes() public view returns (uint[] memory count) {
        (count,) = countVotes_();
    }

    function countVotes_() private view returns (uint[] memory count, uint32[] memory pi) {
        uint32 n = uint32(graph.length);
        count = new uint[](n);
        DfsColor[] memory color = new DfsColor[](n);
        pi = NegativeDefaultArray.build(n);
    
        // DFS back edges
        uint32[2][] memory backEdges = new uint32[2][](n);  // at most n back edges in any cycle
        uint32 backEdgesLength = 0;  // this is for taking backEdges as a list

        for (uint32 u = 0; u < n; u++) {
            if (color[u] == DfsColor.White) {
                backEdgesLength = dfsVisit(u, color, pi, count, backEdges, backEdgesLength);
            }
        }
        countInCycles(count, backEdges, backEdgesLength, pi);
    }

    /// @dev Assigns the same votes amount to each participant in a cycles. That is done for each
    /// cycle in the graph
    /// @param count Votes received by each participant. This is modified by the function
    /// @param backEdges Back edges of the graph
    /// @param backEdgesLength Number of back edges in the graph
    /// @param pi DFS parents array
    function countInCycles(
        uint[] memory count, 
        uint32[2][] memory backEdges,
        uint32 backEdgesLength,
        uint32[] memory pi
    ) 
        private 
        pure
    {
        for (uint256 i = 0; i < backEdgesLength; i++) {  // for each back edge
            uint32 u = backEdges[i][0];
            uint32 v = backEdges[i][1];

            uint maxCount = count[v];
            // computing max count
            for (uint32 x = u; x != v; x = uint32(pi.getAt(x))) {
                if (count[x] > maxCount) {
                    maxCount = count[x];
                }
            }
            // setting max count to all nodes in cycle
            for (uint32 x = u; x != v; x = uint32(pi.getAt(x))) {
                count[x] = maxCount;
            }
            count[v] = maxCount;
        }
    }

    /// @dev Computes the votes received by each participant accessible from a given one
    /// @param u The participant to start the DFS from
    /// @param color DFS colors array
    /// @param pi DFS parents array
    /// @param count Votes received by each participant. This is modified by the function
    /// @param backEdges Back edges of the graph
    /// @param backEdgesLength Number of back edges in the graph
    /// @return backEdgesLength Number of back edges in the graph after the DFS
    function dfsVisit(
        uint32 u, 
        DfsColor[] memory color, 
        uint32[] memory pi, 
        uint[] memory count, 
        uint32[2][] memory backEdges,
        uint32 backEdgesLength
    )
        private 
        view
        returns (uint32)
    {
        color[u] = DfsColor.Gray;

        for (uint256 i = 0; i < graph[u].length; i++) {
            uint32 v = graph[u][i];
            // even when `v` is gray, wi set `pi[v] = u`. In any case, before the assignemnt, 
            // `pi[v]` is always NIL.
            pi.setAt(v, u);  // @FIXME change name to `vote` or similar, since it is not `pi` anymore

            if (color[v] == DfsColor.White) {  // undiscover vertex
                backEdgesLength = dfsVisit(v, color, pi, count, backEdges, backEdgesLength);

            } else if (color[v] == DfsColor.Gray) {  // cycle found
                backEdges[backEdgesLength++] = [u, v];
            }
            // it's not an else-if 'cause I want it executed when coming out from if above
            if (color[v] == DfsColor.Black) {
                uint voteFromVToU = 1;
                count[u] += count[v] + voteFromVToU;  
            }
        }
        color[u] = DfsColor.Black;

        return backEdgesLength;
    }

    function getWinnerAddress() external view returns (address) {
        uint32 winnerId = getWinnerId();
        return voterIdToAddress[winnerId];
    }

    function getWinnerId() public view returns (uint32) {  
        (uint[] memory count, uint32[] memory pi) = countVotes_();

        (uint32 mostVotesId, bool tied) = isTied(count);
        if (!tied) {
            return mostVotesId;
        }
        uint32 n = uint32(graph.length);
        InstantRunoffSystemBuilder memory systemBuilder = InstantRunoffSystemBuilder({
            targetVotesAmount: count[mostVotesId],
            vote: pi,
            votesAmount: count
        });
        InstantRunoffSystem memory ranks = systemBuilder.buildFrom(voteTime);  
        (TiedPerson.Data[] memory tiedData, uint32 maxTiedCount) = getAll1stPlaceVotes(ranks, n);

        // counting direct votes giving to tied-in-the-first-place (max-tied) people
        TiedPersonHeap.Data memory heap = TiedPersonHeap.build(tiedData, maxTiedCount);

        while (!winnerFound(heap, ranks)) {  
            TiedPerson.Data memory loser = heap.popMin();  // loser (let it be A)

            // TiedPerson.log(loser);

            // loser's first choice (let it be B)
            RepresentativeVote memory loser1stVote = ranks.getFirstInRank(loser.id);

            if (!loser1stVote.none) {
                uint votesToSum = loser.votes;
                
                // B's first choice (let it be C)
                RepresentativeVote memory loser1st1stVote = ranks.getFirstInRank(loser1stVote.choice);

                if (!loser1st1stVote.none && loser1st1stVote.choice == loser.id) {  // C = A (B voted for A)
                    // A voted for B and B voted for A, so B's ranking is empty after loser 
                    // removal. One vote for A is then lost.
                    votesToSum -= 1;  
                }
                uint latestVoteForB = Math.max(loser.oldestVoteTime, loser1stVote.time);
                heap.addVotes(votesToSum, loser1stVote.choice, latestVoteForB);  // all votes for A go to B
            }
            ranks.remove(loser);
        }
        return heap.max.id;
    }

    function getAll1stPlaceVotes(InstantRunoffSystem memory ranks, uint32 n) 
        private 
        pure 
        returns (TiedPerson.Data[] memory tiedData, uint32 maxTiedCount) 
    {
        tiedData = new TiedPerson.Data[](n);
        for (uint32 x = 0; x < n; x++) {
            RepresentativeVote memory x1stVote = ranks.getFirstInRank(x);

            if (!x1stVote.none) {
                if (tiedData.defaultAt(x1stVote.choice)) {  
                    tiedData[x1stVote.choice] = TiedPerson.newData(x1stVote.choice, x1stVote.time);
                    maxTiedCount++;
                } else {
                    tiedData[x1stVote.choice].addVote(x1stVote.time);
                }
            }
        }
    }

    function isTied(uint[] memory count) private pure returns (uint32 mostVotesId, bool tied) {
        uint32 n = uint32(count.length);
        for (uint32 i = 1; i < n; i++) {
            if (count[i] > count[mostVotesId]) {
                mostVotesId = i;
                tied = false;
            } else if (count[i] == count[mostVotesId]) {
                tied = true;
            }
        }
    }

    function winnerFound(
        TiedPersonHeap.Data memory maxTiedPersonsHeap,
        InstantRunoffSystem memory runoffSystem
    ) 
        private
        pure
        returns (bool)
    {
        bool majorityAchieved = 
            maxTiedPersonsHeap.max.votes > uint(runoffSystem.activeVoters) / 2;
        return majorityAchieved || maxTiedPersonsHeap.size == 1;
    }

    function destroy() external onlyIfSenderIsOwner {
        address payable fundsRecipient = payable(owner);
        selfdestruct(fundsRecipient);
    }
}

// @TODO voting states, e.g. disallow vote() after count_votes() is called. Only admin
// can change states
// @TODO time limit for states
// @FIXME read style guide (documentation) and fix code accordingly
// @FIXME arguments references in natspec are sourrounded by ``