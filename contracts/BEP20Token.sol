// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BEP20Token is ERC20 {
    constructor() ERC20("BUSD Token", "BUSD") {
        _mint(msg.sender, 100000000000000000000000000);
    }
}
