// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721Sociable {
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
        string _tokenURI;
        Type _type;
    }
}
