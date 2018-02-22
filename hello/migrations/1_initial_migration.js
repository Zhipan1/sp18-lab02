var Migrations = artifacts.require("./Migrations.sol");
var Greeter = artifacts.require("./Greeter.sol");
var Fibonacci = artifacts.require("./Fibonacci.sol");
var XOR = artifacts.require("./XOR.sol");
var Concat = artifacts.require("./Concat.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Greeter);
  deployer.deploy(Fibonacci);
  deployer.deploy(XOR);
  deployer.deploy(Concat);
};
