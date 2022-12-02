const RepresentativeVoting = artifacts.require("RepresentativeVoting");
const testCases = require("./representative_voting_test_cases.js");

module.exports = async function (callback) {
    var votingSystem = await RepresentativeVoting.deployed();
    votingSystem = await testCases.set100VotersTestCase(votingSystem);

    return callback();
}