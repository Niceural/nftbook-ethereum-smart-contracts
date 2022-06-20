// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title NFT listing, selling
interface INftBook {
    struct ItemListing {
        address creator;
        address owner;
        uint256 price;
        bool isListed;
        bool isSalable;
    }

    event ItemListed(
        address indexed owner,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    /// @notice Lists an NFT which cannot be bought
    function listItem(address nftAddress, uint256 tokenId)
        external
        returns (bool success);

    /// @notice Lists an NFT which can be bought
    function listSalableItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external returns (bool success);
}
