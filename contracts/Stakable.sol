// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Stakable is Ownable
{
    uint private totalstake = 0;
    uint private reward_per_token = 0;

    mapping(address => uint) stakebyuser;
    mapping(address => uint) reward_tally;

    constructor()
    {

    }

    function deposit_stake(uint amount) public
    {
        address operator = _msgSender();
        stakebyuser[operator] = stakebyuser[operator] + amount;
        reward_tally[operator] = reward_tally[operator] + reward_per_token * amount;
        totalstake = totalstake + amount;
    }

    function distribute(uint reward) internal onlyOwner
    {
        reward_per_token = reward_per_token + reward / totalstake;
    }

    function withdraw_stake(uint amount) public 
    {
        address operator = _msgSender();
        stakebyuser[operator] =  stakebyuser[operator] - amount;
        reward_tally[operator] = reward_tally[operator] - reward_per_token * amount;
    }

    function compute_reward(address useraddress) public view returns(uint)
    {
        return stakebyuser[useraddress] * reward_per_token - reward_tally[useraddress];
    }

    function withdraw_reward() public
    {
        address operator = _msgSender();
        uint reward = compute_reward(operator);
        reward_tally[operator] = stakebyuser[operator] * reward_per_token;
        payable(operator).transfer(reward);
    }
}
