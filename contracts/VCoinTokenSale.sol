pragma solidity >=0.4.21 <0.6.0;

import "./VCoinToken.sol";

contract VCoinTokenSale {
  // fields vars will be persisted through blockchain and come with getter function
  address admin;
  VCoinToken public tokenContract;
  uint256 public tokenPrice;
  uint256 public tokensSold;

  event Sell (
      address _buyer,
      uint256 _amount
  );

  // Constructor
  constructor(VCoinToken _tokenContract, uint256 _tokenPrice) public {
    // Assign an admin
    admin = msg.sender;
    tokenContract = _tokenContract;
    tokenPrice = _tokenPrice;
  }

  // multiply, dapp tool called: ds-math
  // internal: like "private"
  // pure: costs no gas
  function multiply(uint x, uint y) internal pure returns (uint z) {
    require(y == 0 || (z = x * y) / y == x);
  }

  function buyTokens(uint256 _numberOfTokens) public payable {
    // Require that value is equal to tokens, msg.value is the amount of wei that costs the function call
    require(msg.value == multiply(_numberOfTokens, tokenPrice));
    // Require that the contract has enough tokens
    require(tokenContract.balanceOf(address(this)) >= _numberOfTokens);
    // Require that a transfer is successful
    require(tokenContract.transfer(msg.sender, _numberOfTokens));

    // Keep track of tokensSold
    tokensSold += _numberOfTokens;

    // Trigger Sell Event
    emit Sell(msg.sender, _numberOfTokens);
  }

  // Ending Token VCoinTokenSale
  function endSale() public {
    // Require admin
    require(msg.sender == admin);
    // Transfer remaining dapp tokens back to admin
    require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))));
    // Destroy contract
    // Implicit conversions from address payable to address are allowed,
    // whereas conversions from address to address payable are not possible
    //(the only way to perform such a conversion is by using an intermediate conversion to uint160).
    // https://ethereum.stackexchange.com/questions/62222/address-payable-type-store-address-and-send-later-using-solidity-0-5-0
    selfdestruct(address(uint160(admin)));

    /* // UPDATE: Let's not destroy the contract here
    // Just transfer the balance to the admin
    admin.transfer(address(this).balance); */
  }
}
