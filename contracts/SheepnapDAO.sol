// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Stakable.sol";
import "./Voting.sol";
/**
 * @title Sheepnap DAO.
 * @dev Set & change owner
 */
contract SheepnapDAO is Stakable
{
    using SafeMath for uint256;

    ERC20 private token;
    //==== DAO system parameters ===
    uint private tokenAmountForApprovalRequest = 100;
    uint private approvalRequestDaysToVote = 10; 
    uint private approvalPercentage = 50;
    uint private minimalPercentageVoters = 30; 
    
    struct Property 
    {
        bool isApproved;
        uint totalYes;
        uint totalVoters;
        uint registrationDate;
        bool activeVoting;
        uint treasureAmount;
    }

    mapping(address => Property) private properties;
    //voters, accommodation contract, vote
    mapping(address => mapping(address => bool)) private voters;

    constructor(address _tokenaddress)
        Stakable(ERC20(_tokenaddress))
    {
        token = ERC20(_tokenaddress);
    }

    function getTokenAmountForApprovalRequest() public view returns (uint){
        return tokenAmountForApprovalRequest;
    }

    function getApprovalRequestDaysToVote() public view returns (uint){
        return approvalRequestDaysToVote;
    }

    function getApprovalPercentage() public view returns (uint){
        return approvalPercentage;
    }

    function getMinimalPercentageVoters() public view returns (uint){
        return minimalPercentageVoters;
    }

    function getApprovalRequestInfo(address _propertyaddress) public view returns (Property memory)
    {
        return properties[_propertyaddress];
    }

    function getPropertyActiveVoting(address _propertyaddress) 
        public view returns(bool)
    {
        return properties[_propertyaddress].activeVoting;
    }

    function approvalRequest(address _propertyaddress) public
    {
        require(!properties[_propertyaddress].activeVoting
        , 'Accommodation has an active voting process');

        require(token.balanceOf(msg.sender) >= tokenAmountForApprovalRequest, 
            'Incorrect amount for approval request');

        Property memory newProperty = Property(
        {
          isApproved : false,
          totalYes : 0,
          totalVoters : 0,
          registrationDate : block.timestamp,
          activeVoting : true,
          treasureAmount : tokenAmountForApprovalRequest
        });

        properties[_propertyaddress] = newProperty;
        token.transferFrom(msg.sender, address(this), tokenAmountForApprovalRequest);
    }

    function vote(
      address _propertyaddress, 
      bool _vote) public 
    {
        require(stakersActive[msg.sender], 'Voter must be an staker');
        require(stakers[msg.sender].balance > 0, 'Voter must have active stake');
        
        //require(voters[_propertyaddress][msg.sender], "The voter already voted.");

        require(properties[_propertyaddress].activeVoting, 'Accommodation has not active voting');
        require(checkExpiry(properties[_propertyaddress].registrationDate), 'Voting has ended');

        Property storage property = properties[_propertyaddress];
        if(_vote){
            property.totalYes++;
        }

        property.totalVoters++;
    }       

    function checkExpiry(uint _starttimestamp) private view returns(bool)
    {   
        return _starttimestamp + (approvalRequestDaysToVote * 1 days) >= block.timestamp;     
    }

    function getVotingPower(address _stakerAddress) public view returns (uint256)
    {
        return stakers[_stakerAddress].balance;
    }

    function finalizevoting(address _propertyaddress) public 
    {   
        require(properties[_propertyaddress].activeVoting, "Voting is ended");
        require(checkExpiry(properties[_propertyaddress].registrationDate), 'Voting has not ended');

        Property storage property = properties[_propertyaddress];
        
        if(getPercentage(property.totalYes, property.totalVoters) > approvalPercentage
            && getPercentage(property.totalVoters, totalStakers) > minimalPercentageVoters)
        {
            property.isApproved = true;
        }

        property.activeVoting = false;
    }

    function withdrawvotingrewards(address _propertyaddress) public 
    {
        require(!properties[_propertyaddress].activeVoting, "Voting has not ended");
        Property storage property = properties[_propertyaddress];
        uint rewards = property.treasureAmount.div(property.totalVoters);
        token.transferFrom(address(this), msg.sender, rewards);
    }

    function getPercentage(uint _amount,  uint _totalamount) private pure returns (uint)
    {
        return _amount.mul(100).div(_totalamount);
    }

    //=== EVENTS ===== //
    event ApprovalRequestCreated(address _accommodation);
    event Voting(address indexed user, bool vote);
    event WithdrawRewards(address _staker);
}