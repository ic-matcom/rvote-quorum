const {firstNInList} = require('../lib/list_utils');
var votingSystem = artifacts.require("RepVoting");

module.exports = function(deployer, _, accounts) {
    const VOTERS_AMOUNT = 13;
    var voterAccounts = firstNInList(VOTERS_AMOUNT, accounts);
    deployer.deploy(votingSystem, voterAccounts, {from: voterAccounts[0]});
};
