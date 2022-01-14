// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Staking.sol";
import "./Voting.sol";
/**
 * @title Sheepnap DAO.
 * @dev Set & change owner
 */
contract SheepnapDAO is Staking, Voting
{
    ERC20 private woolToken;

    constructor(address _woolToken)
        Staking(ERC20(_woolToken))
    {
        woolToken = ERC20(_woolToken);
        woolTokensToApprovalRequest = 100;
    }
    
    uint private woolTokensToApprovalRequest;
    
    mapping(address => Accommodation) private accommodations;

    struct Accommodation {
        bool isApproved;
        uint totalYes;
        uint totalVoters;
        uint registrationDate;
        bool activeVoting;
    }

    function vote(
      address _accomodationaddress, 
      bool _vote) public 
    {
        require(stakersActive[msg.sender], 'Voter must stake');
        require(stakers[msg.sender].amount > 0, 'Voter must stake');

        Accommodation storage accommodation = accommodations[_accomodationaddress];
        if(_vote){
            accommodation.totalYes += getVotingPower(msg.sender);
        }
    }

    function getVotingPower(address _stakerAddress) 
    public view returns (uint256)
    {
        return stakers[_stakerAddress].amount;
    }

    function startAccomodationApprovalRequest(
        address _accomodationaddress
      , uint256 _amount) public
    {
        require(!accommodations[_accomodationaddress].activeVoting
        , 'Accommodation has an active voting process');

        require(_amount == 100, 'Incorrect amount');

        woolToken.transfer(address(this), _amount);

        Accommodation memory newAccommodation = Accommodation(
        {
          isApproved : false,
          totalYes : 0,
          totalVoters : 0,
          registrationDate : 0,
          activeVoting : true
        });

        accommodations[_accomodationaddress] = newAccommodation;
    }

    function finalizevoting(address accomodationaddress) public 
    {
        require(accommodations[accomodationaddress].activeVoting, 
        "Voting is ended");
    }

    event Voting(address indexed user, bool vote);
}