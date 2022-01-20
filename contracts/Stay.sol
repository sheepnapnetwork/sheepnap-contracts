// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Accomodation Contract.
 * @dev Set & change owner
 */
contract Stay
{

    constructor() public 
    {

    }

    string private name;
    string private staticDataRefence;

    struct Coordinate {
        uint256 lat;
        uint256 long;
    }

    function getAddress() public view returns (address) {
        return address(this);
    }    

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    
}