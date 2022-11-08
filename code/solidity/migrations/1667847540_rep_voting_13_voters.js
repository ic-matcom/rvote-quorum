var RepVoting = artifacts.require("RepVoting");

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(RepVoting, 13);
};
