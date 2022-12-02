const RepresentativeVoting = artifacts.require("RepresentativeVoting");
const testCases = require("./representative_voting_test_cases.js");
const set100VotersTestCase = testCases.set100VotersTestCase;
const get100VotersTestCaseSpecialVoters = testCases.get100VotersTestCaseSpecialVoters;
const MAX_COUNT_100_VOTERS_TEST_CASE = testCases.MAX_COUNT_100_VOTERS_TEST_CASE;
const timeUtils = require("../lib/time_utils");


contract("RepresentativeVoting", function (accounts) {
    var votingSystem;

    it("should set the 100 voters test case", async function () {
        assert.isTrue(accounts.length >= 100, "there should be at least 100 accounts")
        votingSystem = await RepresentativeVoting.deployed();
        votingSystem = await set100VotersTestCase(votingSystem);
    });
    it(
        "should get winner when 22 voters are tied on first place from a total of 100 voters", 
        async function () {
            const {time, _} = await timeUtils.getElapsedTimeInMillisecondsAndResultAsync(
                async () => await votingSystem.getWinnerId()
            );
            console.log(`${time}ms elapsed to get winner`);
        }
    );
    it(
        "should count properly when 22 voters are tied on first place from a total of 100 voters", 
        async function () {
            const votesCount = await votingSystem.countVotes();
            const testCaseSpecialVoters = get100VotersTestCaseSpecialVoters();
            const {
                MAX_TIED_IN_TREE_VOTER,
                MAX_TIED_IN_CYCLE_OF_4,
                MAX_TIED_IN_CYCLE_OF_16
            }
                = testCaseSpecialVoters;
            assert.equal(
                MAX_COUNT_100_VOTERS_TEST_CASE, 
                votesCount[MAX_TIED_IN_TREE_VOTER],
                "the count of the max-tied voter in the tree is not correct"
            );
            assert.equal(
                MAX_COUNT_100_VOTERS_TEST_CASE, 
                votesCount[MAX_TIED_IN_CYCLE_OF_4],
                "the count of the max-tied voter in the cycle of 4 is not correct"
            );
            assert.equal(
                MAX_COUNT_100_VOTERS_TEST_CASE, 
                votesCount[MAX_TIED_IN_CYCLE_OF_16],
                "the count of the max-tied voter in the cycle of 16 is not correct"
            );
            assertThereAre21MaxTiedVoters(votesCount);
        }
    );
});

contract("RepresentativeVoting", function (accounts) {
    it("should get winner after registering votes using addresses", async function () {
        assert.isTrue(
            accounts.length >= 13, 
            "should has at least 13 accounts but only has " + accounts.length
        );
        
        const votingSystem = await RepresentativeVoting.deployed();                 // (0)
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

        const winner = await votingSystem.getWinnerId();
        assert.equal(winner, 5, "wrong winner");
    });
    it("should abort with an 'only owner allowed' error", async () => {
        const votingSystem = await RepresentativeVoting.deployed();
        
        let assertPromiseRaisesErrorMessage = require("./exceptions.js")
            .assertPromiseRaisesErrorMessage;
        let notOwner = accounts[1];
        let onlyOwnerErrorMessage = "only owner can call this function";

        await assertPromiseRaisesErrorMessage(
            votingSystem.voteFromVoterIdToVoterId(1, 2, {from: notOwner}), 
            onlyOwnerErrorMessage
        );
    });
});

function assertThereAre21MaxTiedVoters(votesCount) {
    let maxTiedCount = 0;
    for (let i = 0; i < votesCount.length; i++) {
        if (votesCount[i] == MAX_COUNT_100_VOTERS_TEST_CASE) {
            maxTiedCount++;
        }
    }
    assert.equal(
        21, 
        maxTiedCount, 
        "there should be 21 max-tied voters but there are " + maxTiedCount
    );
}