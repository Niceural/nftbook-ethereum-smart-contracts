// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title NFT Book allows the user to list, sell, buy NFTs
/// @author Nicolas Bayle
interface INftMarketplace {
    struct ItemListing {
        address creator;
        address owner;
        uint256 minPrice;
        uint256 state; // 0: not listed, 1: listed not salable, 2: listed salable
    }

    event ItemListed(
        address indexed owner,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 minPrice,
        uint256 state
    );

    event ItemListingCanceled(
        address owner,
        address nftAddress,
        uint256 tokenId
    );

    event ItemBought(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 minPrice
    );

    /// @notice Lists an NFT which cannot be bought
    function listItem(address nftAddress, uint256 tokenId) external;

    /// @notice Lists an NFT which can be bought
    function listSalableItem(
        address nftAddress,
        uint256 tokenId,
        uint256 minPrice
    ) external;

    /// @notice Cancel a listing from NFT book
    function cancelItemListing(address nftAddress, uint256 tokenId) external;

    /// @notice
    function makeItemUnsalable(address nftAddress, uint256 tokenId) external;

    /// @notice
    function makeItemSalable(
        address nftAddress,
        uint256 tokenId,
        uint256 minPrice
    ) external;

    /// @notice
    function buyItem(address nftAddress, uint256 tokenId) external payable;

    function withdrawProceeds() external;

    /// @notice
    function getItemListing(address nftAddress, uint256 tokenId)
        external
        view
        returns (ItemListing memory);

    /// @notice
    function getProceeds(address seller) external view returns (uint256);
}
