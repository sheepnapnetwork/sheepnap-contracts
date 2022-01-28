// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Stakable
{
  struct Staker
  {
      uint256 balance;
      uint256 timestampSince;      
  }

  ERC20 private woolToken;
  
  mapping(address => Staker) internal stakers;
  mapping(address => bool) internal stakersActive;
  uint internal totalStakers;
  uint internal treasure;

  constructor(ERC20 _woolToken) 
  {
    woolToken = _woolToken;
  }

  function stake(uint _stakingamount) public
  {
    require(_stakingamount > 0, "Staking amount should be greater than 0");

    Staker memory staker = Staker(
    {
      balance : _stakingamount,
      timestampSince : block.timestamp
    });
    
    stakersActive[msg.sender] = true;    
    stakers[msg.sender] = staker;
    woolToken.transferFrom(msg.sender, address(this), _stakingamount);
  }

  function unstake() public 
  {
    require(stakersActive[msg.sender], 'address is not currently staking');

    woolToken.transfer(address(this), stakers[msg.sender].balance);
    stakersActive[msg.sender] = false;
  }

  function getStakeAmount() public view returns (uint)
  {
    return stakers[msg.sender].balance;
  }

  function addAmountToTreasure(uint _amount) internal
  {
    treasure += _amount;
  }

  function getStakeInfluence(address _address) internal view returns (uint)
  {
    return woolToken.balanceOf(_address);
  }

  /* ========== EVENTS ========== */
  event RewardAdded(uint256 reward);
  event Staked(address indexed user, uint256 amount);
  event Withdrawn(address indexed user, uint256 amount);
  event RewardPaid(address indexed user, uint256 reward);
  event RewardsDurationUpdated(uint256 newDuration);
  event Recovered(address token, uint256 amount);
}
