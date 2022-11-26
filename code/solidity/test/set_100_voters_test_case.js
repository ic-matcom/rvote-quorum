const RepVoting = artifacts.require("RepVoting");
const testCases = require("./rep_voting_test_cases.js");

module.exports = async function (callback) {
    var votingSystem = await RepVoting.deployed();
    votingSystem = await testCases.set100VotersTestCase(votingSystem);

    return callback();
}