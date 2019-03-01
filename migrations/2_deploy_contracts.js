var VCoinToken = artifacts.require("./VCoinToken.sol");
var VCoinTokenSale = artifacts.require("./VCoinTokenSale.sol");

module.exports = function(deployer) {
  // pass in the amount of initial supply into the contract constructor
  deployer.deploy(VCoinToken, 1000000).then(function() {
    // Token price is 0.001 Ether
    var tokenPrice = 1000000000000000;
    return deployer.deploy(VCoinTokenSale, VCoinToken.address, tokenPrice);
  });
};
