// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.25 <0.9.0;

import "truffle/Assert.sol";
import '../contracts/TiedPersonHeap.sol';
import '../contracts/TiedPerson.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import './Array.sol';

contract TestTiedPerson {
    using TiedPerson for TiedPerson.Data;

    function testAddVote() external {
        TiedPerson.Data[] memory data = new TiedPerson.Data[](5);
        data[1] = TiedPerson.newData(1, 13);
        data[3] = TiedPerson.newData(3, 6);
        data[4] = TiedPerson.newData(4, 15);

        data[3].addVote(9);

        uint[] memory expected = new uint[](3);
        expected[0] = 1; 
        expected[1] = 2; 
        expected[2] = 1;

        uint[] memory got = new uint[](3);
        got[0] = data[1].votes; 
        got[1] = data[3].votes; 
        got[2] = data[4].votes; 
    
        Assert.equal(
            got, 
            expected, 
            string.concat(
                "expected votes: ", 
                Array.toString(expected), 
                ", got: ", 
                Array.toString(got))
        );

        expected[0] = 13;
        expected[1] = 9;
        expected[2] = 15;

        got[0] = data[1].oldestVoteTime; 
        got[1] = data[3].oldestVoteTime; 
        got[2] = data[4].oldestVoteTime; 

        Assert.equal(
            got, 
            expected, 
            string.concat(
                "expected times: ", 
                Array.toString(expected), 
                ", got: ", 
                Array.toString(got))
        );
    }
}