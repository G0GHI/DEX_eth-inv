// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract INVtokenCreator is ERC20 {
    constructor() public ERC20("Investor", "INV") {
        _mint(msg.sender, 1000000000 * (10**18));
    }
}
