// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.25 <0.9.0;

import "truffle/Assert.sol";
import "../contracts/TiedPersonHeap.sol";
import "../contracts/TiedPerson.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Array.sol";

contract TestTiedPersonHeap {
    using TiedPerson for TiedPerson.Data;
    using TiedPersonHeap for TiedPersonHeap.Data;

    function testBuild() external {
        TiedPerson.Data[] memory data = new TiedPerson.Data[](10);
        data[0] = TiedPerson.newData(0, 1);
        data[1] = TiedPerson.newData(1, 13);
        data[3] = TiedPerson.newData(3, 6);
        data[4] = TiedPerson.newData(4, 15);
        data[5] = TiedPerson.newData(5, 22);
        data[6] = TiedPerson.newData(6, 10);
        data[8] = TiedPerson.newData(8, 2);
        data[9] = TiedPerson.newData(9, 100);

        data[1].addVote(9);  // max time: 13
        data[4].addVote(1);  // max time: 15
        data[5].addVote(7);  // max time: 22
        data[6].addVote(10); // max time: 10
        data[8].addVote(3);  // max time: 3

        uint32 size = 8;
        TiedPersonHeap.Data memory heap = TiedPersonHeap.build(data, size);
    
        Assert.equal(
            heap.size, 
            size, 
            "wrong heap size"
        );
        Assert.equal(
            heap.max.id, 
            8,  // 8 has the highest vote count (2) and the lowest time (3)
            "wrong max ID"
        );
        Assert.equal(
            heap.tree[0].data.id,
            9,  // 9 has the lowest vote count (1) and the highest time (100)
            "wrong min ID"
        );
        Assert.equal(
            heap.tree[0].idx,
            0, 
            "wrong min index"
        );
    }

    function testPopMin() external {
        TiedPerson.Data[] memory data = new TiedPerson.Data[](10);
        data[0] = TiedPerson.newData(0, 1);
        data[1] = TiedPerson.newData(1, 13);
        data[3] = TiedPerson.newData(3, 6);
        data[4] = TiedPerson.newData(4, 15);
        data[5] = TiedPerson.newData(5, 22);
        data[6] = TiedPerson.newData(6, 10);
        data[8] = TiedPerson.newData(8, 2);
        data[9] = TiedPerson.newData(9, 100);

        data[1].addVote(9);  // max time: 13
        data[4].addVote(1);  // max time: 15
        data[5].addVote(7);  
        data[5].addVote(3);  // max time: 22 votes: 3
        data[6].addVote(10); 
        data[6].addVote(40); // max time: 40 votes: 3
        data[8].addVote(3);  // max time: 3

        uint32 size = 8;
        TiedPersonHeap.Data memory heap = TiedPersonHeap.build(data, size);
    
        Assert.equal(
            heap.size, 
            size, 
            "wrong heap size"
        );
        Assert.equal(
            heap.max.id, 
            5,  // 5 has the highest vote count (3) and the lowest time (22)
            "wrong max ID"
        );
        uint[] memory expectedMins = new uint[](size);
        // votes = 1
        expectedMins[0] = 9;
        expectedMins[1] = 3;
        expectedMins[2] = 0;
        // votes = 2
        expectedMins[3] = 4;
        expectedMins[4] = 1;
        expectedMins[5] = 8;
        // votes = 3
        expectedMins[6] = 6;
        expectedMins[7] = 5;

        uint[] memory gotMins = new uint[](size);
        for (uint256 i = 0; i < gotMins.length; i++) {
            gotMins[i] = heap.popMin().id;
        }
        Assert.equal(
            gotMins,
            expectedMins,
            string.concat(
                "wrong min sequence (Expected: ", 
                Array.toString(expectedMins), 
                ", Got: ",
                Array.toString(gotMins),
                ")"
            )
        );
        Assert.equal(0, heap.size, "wrong size");
    }

    function testAddVotes() external {
        TiedPerson.Data[] memory data = new TiedPerson.Data[](10);
        data[0] = TiedPerson.newData(0, 1);
        data[1] = TiedPerson.newData(1, 13);
        data[3] = TiedPerson.newData(3, 6);
        data[4] = TiedPerson.newData(4, 15);
        data[5] = TiedPerson.newData(5, 22);
        data[6] = TiedPerson.newData(6, 10);
        data[8] = TiedPerson.newData(8, 2);
        data[9] = TiedPerson.newData(9, 100);

        uint32 size = 8;
        TiedPersonHeap.Data memory heap = TiedPersonHeap.build(data, size);
    
        heap.addVotes(1, 1, 9);  // max time: 13 votes: 2
        heap.addVotes(1, 4, 1);  // max time: 15 votes: 2
        heap.addVotes(1, 8, 3);  // max time: 3 votes: 2
        heap.addVotes(2, 5, 7);  // max time: 22 votes: 3
        heap.addVotes(2, 6, 40);  // max time: 40 votes: 3

        Assert.equal(
            heap.max.id, 
            5,  // 5 has the highest vote count (3) and the lowest time (22)
            "wrong max ID"
        );
        Assert.equal(
            heap.max.oldestVoteTime, 
            22,  // 5 has the highest vote count (3) and the lowest time (22)
            "wrong max oldest vote time"
        );
        Assert.equal(
            heap.tree[0].data.id,
            9,  // 9 has the lowest vote count (1) and the highest time (100)
            "wrong min ID"
        );
        Assert.equal(
            heap.tree[0].idx,
            0, 
            "wrong min index"
        );
        uint[] memory expectedMins = new uint[](size);
        // votes = 1
        expectedMins[0] = 9;
        expectedMins[1] = 3;
        expectedMins[2] = 0;
        // votes = 2
        expectedMins[3] = 4;
        expectedMins[4] = 1;
        expectedMins[5] = 8;
        // votes = 3
        expectedMins[6] = 6;
        expectedMins[7] = 5;

        uint[] memory gotMins = new uint[](size);
        for (uint256 i = 0; i < gotMins.length; i++) {
            gotMins[i] = heap.popMin().id;
        }
        Assert.equal(
            gotMins,
            expectedMins,
            string.concat(
                "wrong min sequence (Expected: ", 
                Array.toString(expectedMins), 
                ", Got: ",
                Array.toString(gotMins),
                ")"
            )
        );
        Assert.equal(0, heap.size, "wrong size");
    }
}