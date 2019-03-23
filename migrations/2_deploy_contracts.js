const ticketingSystem = artifacts.require("ticketingSystem.sol");

module.exports = function(deployer) {
  deployer.deploy(ticketingSystem);
};
