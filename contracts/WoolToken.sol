// contracts/ExampleToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WoolToken is ERC20 {
  constructor()
  ERC20("WOOL", "WOL") {
    _mint(
      msg.sender,
      2000000 * 10 ** decimals()
    );
  }
}