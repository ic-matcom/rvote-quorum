// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.22 <0.9.0;

import './TiedPerson.sol';
import '@openzeppelin/contracts/utils/math/Math.sol';

/// @author Andy Ledesma García
/// @title Heap of `TiedPerson.Data` instances
/// @dev Heap of `TiedPerson.Data` instances. It's used to get the person with the 
/// minimum amount of votes acquired at the latest time
library TiedPersonHeap {
    using TiedPersonHeap for TiedPerson.Data;
    using TiedPersonHeap for Node;
    using {TiedPersonHeap.defaultAt} for Node[];
    using TiedPersonHeap for TiedPersonHeap.Data;
    using {TiedPerson.defaultAt} for TiedPerson.Data[];

    /// @dev Heap tree node
    struct Node {
        TiedPerson.Data data;
        
        /// @dev Index in the tree array
        uint32 idx;
    }

    /// @dev Heap data. This and the heap are treated as the same
    struct Data {  
        Node[] tree;

        /// @dev `dict[x]` := node in the heap with `x` as `data.id`, default value if not in heap
        Node[] dict;
        TiedPerson.Data max;
        uint32 size;
    }

    /// @dev Should be taken as the constructor of the heap
    /// @param data Non-default values must be added to the heap
    /// @param heapSize The size of the heap, i.e. number of non-default values of `data`
    function build(TiedPerson.Data[] memory data, uint32 heapSize) 
        internal 
        pure 
        returns (TiedPersonHeap.Data memory heap) 
    {
        heap.tree = new Node[](heapSize);
        heap.size = heapSize;
        heap.dict = new Node[](data.length);

        // filling `heap.tree` and `heap.dict`
        uint32 idx; 
        for (uint32 x = 0; x < data.length; x++) {
            if (!data.defaultAt(x)) {  // `data[x]` should belong to heap
                Node memory node = Node({data: data[x], idx: idx}); 
                heap.tree[idx++] = node;
                heap.dict[x] = node;
            }
        }
        require (
            idx == heap.size, 
            "`heapSize` must equal number of available data in data argument"
        );
        // building heap
        for (int32 i = int32(heap.size/2) - 1; i >= 0; i--) {
            heapify(heap, uint32(i));
        }

        // finding maximum. Once heap is built, max is one of the leaves, i.e., 
        // interval [heap.size/2, heap.size)
        heap.max = heap.tree[heap.size/2].data;
        for (uint256 i = heap.size / 2 + 1; i < heap.size; i++) {
            if (heap.max.lowerThan(heap.tree[i].data)) {
                heap.max = heap.tree[i].data;
            }
        }
    }

    function heapify(TiedPersonHeap.Data memory self, uint32 i) 
        private 
        pure 
    {
        uint32 left = 2 * i + 1;
        uint32 right = 2 * i + 2;
        uint32 lowest = i;

        if (left < self.size && self.tree[left].lowerThan(self.tree[lowest])) {  
            // left child is lower
            lowest = left;
        }
        if (right < self.size && self.tree[right].lowerThan(self.tree[lowest])) {  
            // right child is the lowest
            lowest = right;
        }
        if (lowest != i) {  // parent must be swapped with lowest child
            Node memory tmp = self.tree[i];
            self.tree[i] = self.tree[lowest];
            self.tree[lowest] = tmp;

            // updating indices
            self.tree[i].idx = i;
            self.tree[lowest].idx = lowest;

            heapify(self, lowest);
        }
    }

    function lowerThan(TiedPerson.Data memory self, TiedPerson.Data memory other) 
        internal 
        pure 
        returns (bool) 
    {
        if (self.votes == other.votes) {
            return self.oldestVoteTime > other.oldestVoteTime;  // oldest first
        }
        return self.votes < other.votes;
    }

    function lowerThan(Node memory self, Node memory other) 
        internal 
        pure 
        returns (bool) 
    {
        return self.data.lowerThan(other.data);
    }

    function popMin(TiedPersonHeap.Data memory self) 
        internal 
        pure 
        returns (TiedPerson.Data memory ans) 
    {
        require(self.size > 0, 'Heap is empty');

        ans = self.tree[0].data;
        self.tree[0] = self.tree[self.size - 1];
        self.tree[0].idx = 0;
        self.size -= 1;
        heapify(self, 0);
    }

    /// @dev Adds votes to a person and updates heap accordingly
    /// @param votes Votes to add
    /// @param targetId Id of the person to add votes to
    /// @param maxVoteTime Time of the latest vote to add
    function addVotes(
        TiedPersonHeap.Data memory self, 
        uint votes, 
        uint32 targetId,
        uint maxVoteTime
    ) 
        internal 
        pure 
    {
        require (!self.dict.defaultAt(targetId), "targetId is not a max-tied person's ID.");

        Node memory target = self.dict[targetId];
        target.data.votes += votes;
        target.data.oldestVoteTime = Math.max(maxVoteTime, target.data.oldestVoteTime);  

        if (self.max.lowerThan(target.data)) {  // updating max
            self.max = target.data;
        }
        heapify(self, target.idx);
    }

    function defaultAt(Node[] memory self, uint32 id) internal pure returns (bool) {
        return !self[id].data.nonDefault;
    }
}
// @TODO averiguar co'mo hago pa q las dependencias (e.g. openzeppeling) puedan ser instaladas 
// fa'cilmente x el q le haga git clone a este repo