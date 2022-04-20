// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Booken is ERC721, Ownable {

    using Strings for uint256;

    enum Status { OPEN, CANCELLED, CANCELLEDBYHOST, ONSALE }
    enum RoomType { SGL, DBL, TPL }

    constructor(string memory propertyname) 
        ERC721(string(abi.encodePacked("Booken for ", propertyname)), "BKN") {
    }

   struct BookenData {
      uint256 tokenId;
      uint256 roomcode;
      RoomType roomtype;
      uint checkin;
      uint price;
      uint maxadults;
   }

    mapping(uint => BookenData) private _bookenData;

    function safeMint(
        uint tokenId,
        address to,
        uint256 roomcode,
        uint roomtype,
        uint256 checkin,
        uint256 price,
        uint256 maxadults

    ) public onlyOwner 
    {
        _bookenData[tokenId] = BookenData(tokenId, roomcode, RoomType(roomtype), checkin, price, maxadults);
        _safeMint(to, tokenId);
    }

    function bookenData(uint bookenCode) public view returns(BookenData memory)
    {
        return _bookenData[bookenCode];
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) 
    {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        uint roomtype = uint(_bookenData[tokenId].roomtype);
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, roomtype.toString())) : "";
    }
}