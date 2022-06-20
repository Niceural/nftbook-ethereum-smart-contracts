// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title NFT Book allows the user to list, sell, buy NFTs
/// @author Nicolas Bayle
interface INftBook {
    struct ItemListing {
        address creator;
        address owner;
        uint256 price;
        uint256 state; // 0: not listed, 1: listed not salable, 2: listed salable
    }

    event ItemListed(
        address indexed owner,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    event ItemUnlisted(address owner, address nftAddress, uint256 tokenId);

    event ItemBought(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    /// @notice Lists an NFT which cannot be bought
    function listItem(address nftAddress, uint256 tokenId) external;

    /// @notice Lists an NFT which can be bought
    function listSalableItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external;

    /// @notice Cancel a listing from NFT book
    function unlistItem(address nftAddress, uint256 tokenId) external;

    /// @notice
    function makeItemUnsalable(address nftAddress, uint256 tokenId) external;

    /// @notice
    function makeItemSalable(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external;

    /// @notice
    function buyItem(address nftAddress, uint256 tokenId) external payable;
}
