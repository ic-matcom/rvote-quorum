var votingSystem = artifacts.require("RepVoting");

function first13Accounts(accounts) {
    return accounts.slice(0, 13);
}

module.exports = function(deployer, _, accounts) {
    var voterAccounts = first13Accounts(accounts);
    deployer.deploy(votingSystem, voterAccounts, {from: voterAccounts[0]});
};
