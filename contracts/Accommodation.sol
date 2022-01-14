// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Accomodation Contract.
 * @dev Set & change owner
 */
contract Accomodation
{
    string private name;
    string private staticDataRefence;

    struct Coordinate {
        uint256 lat;
        uint256 long;
    }

    function getAddress() public view returns (address) {
        return address(this);
    }    
}