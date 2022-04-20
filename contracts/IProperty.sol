
//represent the property entity used by de DAO.
interface IProperty {

    enum RoomType { SGL, DBL, TPL }
    enum PropertyType { Apartment, Hotel, Hostel, Motel, Resort }
    enum BookenStatus { OPEN, CANCELLED, CANCELLEDBYHOST, ONSALE }

    function getMetadataUri() external view returns(string memory);

    //Booken operations
    function buyBookens(uint[] memory _bookencodes) external;
    function emitBookens(uint[] memory codes, RoomType _roomtype, uint roomcode, uint price) external;
    function updateBookenPrices(uint[] memory codes, uint price) external;

    //=== only property owner operator
    function updateStatus(uint[] memory _bookencodes, BookenStatus bookenStatus) external;

    //== events ==
    event PropertyMetadataChange();
    event Withdraw();

    event BookenEmit();
    event BookenStatusUpdate();
    event BookenUpdatePrice();
}