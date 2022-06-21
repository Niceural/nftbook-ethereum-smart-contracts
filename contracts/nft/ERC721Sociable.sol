// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721Sociable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract ERC721Sociable is IERC721Sociable, ERC721URIStorage, Ownable {
    // tokenId to Type
    mapping(uint256 => Type) private s_tokenIdToType;
    // tokenId to minter
    mapping(uint256 => address) private s_tokenIdToMinter;

    function _setSociableData(
        uint256 tokenId,
        address minter,
        Type tpe
    ) internal {
        require(_exists(tokenId), "ERC721Sociable: non existant token");
        s_tokenIdToMinter[tokenId] = minter;
        s_tokenIdToType[tokenId] = tpe;
    }

    function getType(uint256 tokenId) public view override returns (Type) {
        return s_tokenIdToType[tokenId];
    }

    function getMinter(uint256 tokenId) public view override returns (address) {
        return s_tokenIdToMinter[tokenId];
    }
}
