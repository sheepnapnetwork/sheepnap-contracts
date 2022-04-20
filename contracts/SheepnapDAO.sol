// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Review.sol";
import "./Stakable.sol";
import "./Property.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Sheepnap DAO.
 * @dev Set & change owner
 */
contract SheepnapDAO is Stakable, Ownable {
    using SafeMath for uint256;

    //== Contracts 
    ERC20 private token;
    Review private _reviewcontract;
    string _daowebsite;

    //==== DAO system parameters ===
    uint256 private tokenAmountForRegister = 1000 * 10 ** 18;
    uint256 private serviceFee = 100000 wei;

    mapping(address => bool) private _approvedProperties;

    constructor(address _tokenaddress) 
        Stakable(ERC20(_tokenaddress)) {
        token = ERC20(_tokenaddress);
    }

    function registerProperty(address _propertyaddress) public 
    {
        require(_approvedProperties[_propertyaddress] == false, "Property is already registered");
        token.transferFrom(msg.sender, address(this), tokenAmountForRegister);
        _approvedProperties[_propertyaddress] = true;
        emit RegisteredProperty(_propertyaddress);
    }

    function approveProperty(address _propertyaddress) public onlyOwner
    {
        _approvedProperties[_propertyaddress] = true;
    }

    function removeProperty(address _propertyaddress) public
    {
        address operator = _msgSender();
        require(Property(_propertyaddress).owner() == operator || operator == owner());
        _approvedProperties[_propertyaddress] = false;
    }

    function buyBooken(address propertyaddress, uint256 bookencode) public payable
    {
       require(msg.value >= serviceFee);
       Property property = Property(propertyaddress);
       //TODO : call data?
       property.buyBooken(bookencode);
    }
    
    function getPropertyIsApproved(address _propertyaddress) public view returns (bool){
        return _approvedProperties[_propertyaddress];
    }

    //=== EVENTS ===== //
    event RegisteredProperty(address _propertycontract);
    event WithdrawRewards(address _staker);
}
