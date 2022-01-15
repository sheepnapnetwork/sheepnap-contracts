// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Staking.sol";
import "./Voting.sol";
/**
 * @title Sheepnap DAO.
 * @dev Set & change owner
 */
contract SheepnapDAO is stakable
{
    using SafeMath for uint256;

    ERC20 private token;
    //==== DAO system parameters ====   
    uint private tokenAmountForApprovalRequest = 100;
    uint private approvalRequestDaysToVote = 10; 
    uint private approvalPercentage = 50;
    uint private minimalPercentageVoters = 30; 
    
    struct Accommodation 
    {
        bool isApproved;
        uint totalYes;
        uint totalVoters;
        uint registrationDate;
        bool activeVoting;
        uint treasureAmount;
    }

    mapping(address => Accommodation) private accommodations;
    //voters, accommodation contract, vote
    mapping(address => mapping(address => bool)) private voters;

    constructor(address _tokenaddress)
    {
        token = ERC20(_tokenaddress);
    }

    function startAccomodationApprovalRequest(
        address _accomodationaddress) public
    {
        require(!accommodations[_accomodationaddress].activeVoting
        , 'Accommodation has an active voting process');

        require(woolToken.balanceOf(msg.sender) >= woolAmountForApprovalRequest, 
            'Incorrect amount for approval request');

        Accommodation memory newAccommodation = Accommodation(
        {
          isApproved : false,
          totalYes : 0,
          totalVoters : 0,
          registrationDate : block.timestamp,
          activeVoting : true,
          treasureAmount : woolAmountForApprovalRequest
        });

        accommodations[_accomodationaddress] = newAccommodation;
        woolToken.transferFrom(msg.sender, address(this), _stakingamount);
    }

    function vote(
      address _accommodationaddress, 
      bool _vote) public 
    {
        require(stakersActive[msg.sender], 'Voter must be an staker');
        require(stakers[msg.sender].amount > 0, 'Voter must have active stake');
        
        require(voters[_accommodationaddress][msg.sender], "The voter already voted.");

        require(accommodations[_accommodationaddress].activeVoting, 'Accommodation has not active voting');
        require(!checkExpiry(accommodations[_accomodationaddress].registrationDate), 'Voting has ended');

        Accommodation storage accommodation = accommodations[_accomodationaddress];
        if(_vote){
            accommodation.totalYes++;
        }

        accommodation.totalVoters++;
    }       

    function checkExpiry() private view returns(uint _starttimestamp)
    {   
        return _starttimestamp + (approvalRequestDaysToVote * 1 days) >= block.timestamp;     
    }

    function getVotingPower(address _stakerAddress) public view returns (uint256)
    {
        return stakers[_stakerAddress].amount;
    }

    function finalizevoting(address _accomodationaddress) public 
    {
        require(accommodations[_accomodationaddress].activeVoting, "Voting is ended");
        require(checkExpiry(accommodations[_accomodationaddress].registrationDate), 'Voting has not ended');
        require(accommodationActiveVoting[_accommodationaddress], 'Accommodation has not active process');

        Accommodation storage accommodation = accommodations[_accomodationaddress];
        
        if(
               getPercentage(accommodation.totalYes, totalVoters) > approvalPercentage
            && getPercentage(totalVoters, totalStakers) > minimalPercentageVoters)
        {
            accommodation.isApproved = true;
        }

        accommodation.activeVoting = false;
    }

    function withdrawvotingrewards(address _accomodationaddress) public 
    {
        require(!accommodations[_accomodationaddress].activeVoting, "Voting has not ended");

        Accommodation storage accommodation = accommodations[_accomodationaddress];
        uint rewards = accommodation.treasureAmount.div(totalVoters);
        token.transferFrom(address(this), msg.sender, rewards);
    }

    function getPercentage(uint _amount,  uint _totalamount) private pure returns (uint)
    {
        return _amount.mul(100).div(_totalamount);
    }

    //=== EVENTS ===== //
    event Voting(address indexed user, bool vote);
        
}