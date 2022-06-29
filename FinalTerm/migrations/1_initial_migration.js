const Migrations = artifacts.require("Migrations");
const Contract = artifacts.require("TRY");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Contract)
};
