pragma solidity >=0.4.21 <0.6.0;

import "./VCoinToken.sol";

contract VCoinTokenSale {
  // fields vars will be persisted through blockchain and come with getter function
  address admin;
  VCoinToken public tokenContract;
  uint256 public tokenPrice;
  uint256 public tokenSold；

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

  function buyTokens(uint256 _numberOfTokens) public payable {
    // Require that value is equal to tokens, msg.value is the amount of wei the function is sending
    require(msg.value == tokenPrice * _numberOfTokens);
    // Require that the contract has enough tokens
    // Require that a transfer is successful


    // Keep track of tokensSold
    tokensSold += _numberOfTokens;

    // Trigger Sell Event
    emit Sell(msg.sender, _numberOfTokens);
  }
}
