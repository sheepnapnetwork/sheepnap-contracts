
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Stakable.sol";
import "./Property.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Reviews
 * @dev Set & change owner
 */
contract Review is Ownable {
    
    struct Rate { 
            uint cleaning;
            uint service;
            uint location;
            uint contentreference;
        }

    uint8 constant DECIMALS = 3;
    //weights
    uint private _weightcleaning = 4;
    uint private _weightservice = 2;
    uint private _weightlocation = 3;

    uint private _totalparameters = 3;

    //properties to address
    mapping(address => mapping(address => Rate)) private ratings;
    mapping(address => uint) private propertyrating;

    function createreview(address propertyaddress, Rate memory rate) public onlyOwner
    {
        ratings[_msgSender()][propertyaddress] = rate;
        propertyrating[propertyaddress] = computetotalrating(rate);
    }
    
    function computetotalrating(Rate memory rate) internal view returns(uint)
    {
        require(rate.cleaning <= 10);
        require(rate.service <= 10);
        
        return ((rate.cleaning  * 10 ** DECIMALS) * _weightcleaning
                + ((rate.service * 10 ** DECIMALS) * _weightservice)
                + ((rate.location * 10 ** DECIMALS) * _weightlocation))
                 / _totalparameters;
    }

    function propertyratingbyaddress(address propertyaddress) public view returns(uint)
    {
        return propertyrating[propertyaddress];
    }
}