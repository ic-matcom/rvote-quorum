// SPDX-License-Identifier: UNLICENSED
// @audit NOTE check if 'UNLICENSED' is suitable
pragma solidity >=0.4.22 <0.9.0;

/// @title Representative voting system
/// @author Andy Ledesma García
contract RepVoting {
  /// @dev (x, y) is an arc of graph <=> y voted by x
  uint32[][] graph;
  bool[] voted;

  /// @param voters The number of voters the system will support
  constructor(uint32 voters) {
    graph = new uint32[][](voters);
    voted = new bool[](voters);
  }

  /// Makes a vote
  /// @param x Who the vote comes from
  /// @param y Who the vote goes to
  /// @dev @TODO removes x and take it from msg.sender. y must be an address
  function vote(uint32 x, uint32 y) external {
    require(!voted[x], "Already voted.");
    graph[y].push(x);
    voted[x] = true;
  }

  enum DfsColor { White, Gray, Black }

  /// Count the votes received by each participant
  /// @return count Votes received by each participant
  function countVotes() public view returns (uint[] memory count) {
    uint32 n = uint32(graph.length);
    count = new uint[](n);
    DfsColor[] memory color = new DfsColor[](n);
    
    // pi[x+1]-1 = parent of x. pi[x+1] = 0 if x is root. NOTE: only access pi by using get(pi,...) 
    // and set(pi,...) functions.
    uint32[] memory pi = new uint32[](n+1);  
    
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
      for (uint32 x = u; x != v; x = uint32(get(pi, x))) {
        if (count[x] > maxCount) {
          maxCount = count[x];
        }
      }
      // setting max count to all nodes in cycle
      for (uint32 x = u; x != v; x = uint32(get(pi, x))) {
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
      if (color[v] == DfsColor.White) {  // undiscover vertex
        set(pi, v, u);
        backEdgesLength = dfsVisit(v, color, pi, count, backEdges, backEdgesLength);

      } else if (color[v] == DfsColor.Gray) {  // cycle found
        backEdges[backEdgesLength++] = [u, v];
      }

      // it's not an else-if 'cause I want it executed when coming out from if above
      if (color[v] == DfsColor.Black) {
        set(pi, v, u);  
        count[u] += count[v] + 1;  // +1 for the vote from v to u
      }
    }
    color[u] = DfsColor.Black;

    return backEdgesLength;
  }

  /// @dev pi[x+1]-1 = parent of x. This function encapsulates that computation so developer
  /// hasn't to worry about adding and substracting 1
  /// @return Parent of x
  function get(uint32[] memory pi, uint32 x) private pure returns (int32) {
    return int32(pi[x+1]-1);
  }

  /// @dev Sets parent of a vertex
  /// @param pi DFS parent array
  /// @param x Target vertex
  /// @param y Parent vertex
  function set(uint32[] memory pi, uint32 x, uint32 y) private pure {
    pi[x+1] = y+1;
  }
}

// @TODO voting states, e.g. disallow vote() after count_votes() is called
// @TODO mapping between address and uint32