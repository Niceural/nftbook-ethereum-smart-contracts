// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Metadata.sol";

interface IERC721Sociable is IERC721, IERC721Metadata {
    enum Type {
        NONE,
        POST,
        ADVERTISEMENT,
        SHORT_VIDEO,
        VIDEO
    }

    struct TokenData {
        address _owner;
        address _approval;
        uint256 _numberOfViews;
        uint256 _numberOfLikes;
        uint256 _numberOfComments;
        Type _type;
        string _tokenURI;
    }

    function tokenData(uint256 tokenId) external returns (TokenData memory);
}
