// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

interface IERC721Sociable is IERC721Metadata {
    //=====================================================================================
    //                                                                                types
    //=====================================================================================
    // type of the NFT
    enum Type {
        NONE,
        POST,
        SHORT_VIDEO,
        MUSIC,
        VIDEO
    }

    function getType(uint256 tokenId) external view returns (Type);

    function getMinter(uint256 tokenId) external view returns (address);
}
