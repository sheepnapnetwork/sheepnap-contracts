// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Booken.sol";
import "./IProperty.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
/**
 * @title property Contract.
 * @dev Set & change owner
 */
contract Property is IProperty, Ownable
{
    using Strings for uint256;

    string private _name;
    string private staticDataRefence;
    Booken private bookenContract;
    ERC20 private paymentToken;

    constructor(address _paymenttoken) { 
        paymentToken = ERC20(_paymenttoken);
        bookenContract = new Booken(_name);
    }

    function emitBookens(
        uint256[] memory _codes,
        uint256[] memory _dates, 
        uint _roomcode, 
        uint price, 
        RoomType roomtype) public onlyOwner
    {
        address operator = _msgSender();
        for (uint256 i = 0; i < _codes.length; i++) {
            bookenContract.safeMint(_codes[i], operator, _roomcode, uint(roomtype), _dates[i], price, 1);
        }
    }

    function buyBooken(uint bookencode) public
    {
       require(bookenContract.ownerOf(bookencode) == address(this), "");
       address operator = _msgSender();
       uint amount = bookenContract.bookenData(bookencode).price;
       paymentToken.transferFrom(operator, address(this), amount);
       bookenContract.safeTransferFrom(address(this), msg.sender, bookencode);
    }

    function withdraw() public onlyOwner
    {
        address operator = _msgSender();
        uint256 amount = paymentToken.balanceOf(address(this));
        paymentToken.transfer(operator, amount);
    }

    function getMetadataUri() public view override returns(string memory)
    {
        return staticDataRefence;
    }
}