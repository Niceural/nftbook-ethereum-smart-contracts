// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./implementation/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("Token", "TKN") {
        // 21,000,000 tokens initial balance
        uint256 initialSupply = 21000000000000000000000000;
        _mint(_msgSender(), initialSupply);
    }
}
