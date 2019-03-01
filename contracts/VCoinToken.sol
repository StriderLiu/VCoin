pragma solidity >=0.4.21 <0.6.0;

contract VCoinToken {
  // fields vars will be persisted through blockchain and come with getter function
  string public name = "VCoin Token";
  string public symbol = "VCOIN";
  uint256 public totalSupply;

  event Transfer(
      address indexed _from,
      address indexed _to,
      uint256 _value
  );

  event Approval(
    address indexed _owner,
    address indexed _spender,
    uint256 _value
  );

  mapping (address => uint256) public balanceOf;
  mapping (address => mapping(address => uint256)) public allowance;

  // Constructor
  constructor(uint256 _initialSupply) public {
    balanceOf[msg.sender] = _initialSupply;
    totalSupply = _initialSupply; // prefix loca l var with
    // allocate the initial supply
  }

  // Transfer, trigger Transfer Event
  // Return a boolean
  // Exception if account doesn't have enough balance
  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(balanceOf[msg.sender] >= _value);

    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;

    emit Transfer(msg.sender, _to, _value);

    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowance[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);

    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    // Require _from has enough tokens
    require(balanceOf[_from] >= _value);
    // Require allowance is big enough
    require(allowance[_from][msg.sender] >= _value);

    // Change the balance
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;

    // Update the allowance
    allowance[_from][msg.sender] -= _value;

    // Transfer event
    emit Transfer(_from, _to, _value);

    // return a boolean
    return true;
  }
}
