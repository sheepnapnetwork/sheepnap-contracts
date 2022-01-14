// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Staking
{
  struct Staker
  {
      uint256 amount;
      uint256 timestampSince;      
  }

  ERC20 private woolToken;
  mapping(address => Staker) internal stakers;
  mapping(address => bool) internal stakersActive;
  uint private treasure;
  constructor(ERC20 _woolToken) 
  {
    woolToken = _woolToken;
  }

  function stake(uint _amount) public
  {
    Staker memory staker = Staker(
    {
      amount : _amount,
      timestampSince : block.timestamp
    });

    //TODO : implement security
    woolToken.transfer(address(this), _amount);
    stakersActive[msg.sender] = true;    
    stakers[msg.sender] = staker;
  }

  function unstake() public 
  {
    require(stakersActive[msg.sender], 'address is not currently staking');
    woolToken.transfer(address(this), stakers[msg.sender].amount);
    stakersActive[msg.sender] = false;
  }

  function withdrawRewards(address _staker) public
  {
      
  } 

  function addAmountToTreasure(uint _amount) internal
  {
    treasure += _amount;
  }

  function getStakeInfluence(address _address) internal view returns (uint)
  {
    return woolToken.balanceOf(_address);
  }


  event StakingStarted(address indexed user, uint256 amount, uint256 index, uint256 timestamp);
}
