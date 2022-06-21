// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721Sociable.sol";

contract NftSociable is ERC721Sociable {
    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
    {}
}
