const RepVoting = artifacts.require("RepVoting");

contract("RepVoting", function (accounts) {
    it("should get winner after registering votes using addresses", async function () {
        assert.isTrue(accounts.length >= 13, "should have at least 13 accounts");
        
        const votingSystem = await RepVoting.deployed();                 // (0)
        await votingSystem.voteFor(accounts[1], {from: accounts[7]});    // (6) -> (7) -> (1)             
        await votingSystem.voteFor(accounts[8], {from: accounts[2]});    //     11   \     v  9
        await votingSystem.voteFor(accounts[4], {from: accounts[8]});    //           -<- (3)
        await votingSystem.voteFor(accounts[7], {from: accounts[3]});    //            4
        await votingSystem.voteFor(accounts[12], {from: accounts[11]});  // (2) -> (8) -> (4) -> (5)
        await votingSystem.voteFor(accounts[10], {from: accounts[9]});   //     2      3      7
        await votingSystem.voteFor(accounts[5], {from: accounts[4]});    //       8
        await votingSystem.voteFor(accounts[9], {from: accounts[12]});   //  (9) <- (12)
        await votingSystem.voteFor(accounts[3], {from: accounts[1]});    // 6 v      ^   5
        await votingSystem.voteFor(accounts[11], {from: accounts[10]});  // (10) -> (11)
        await votingSystem.voteFor(accounts[7], {from: accounts[6]});    //      10

        const winner = await votingSystem.getWinner();
        assert.equal(winner, 5, "wrong winner");
    });
});
