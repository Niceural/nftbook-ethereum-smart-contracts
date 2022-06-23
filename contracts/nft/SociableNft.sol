// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./implementation/ERC721Sociable.sol";
import "../utils/Ownable.sol";

contract SociableNft is ERC721Sociable, Ownable {
    constructor(string memory name, string memory symbol)
        ERC721Sociable(name, symbol)
    {}

    function mint() public {}
}
