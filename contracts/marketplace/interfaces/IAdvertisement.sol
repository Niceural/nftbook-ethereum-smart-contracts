// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

error Advertisement__InvalidNftAddress();
error Advertisement__ItemAlreadyListed(address nftAddress, uint256 tokenId);
error Advertisement__ItemNotListed(address nftAddress, uint256 tokenId);
error Advertisement__NotOwner();
error Advertisement__InsufficientAmountAllowed();

interface IAdvertisement {
    event AdItemListed(address nftAddress, uint256 tokenId);
    event AdAdvertisementRequest(
        address nftAddress,
        uint256 tokenId,
        uint256 fee
    );

    enum AdItemState {
        NOT_LISTED,
        LISTED,
        ADVERTISING
    }

    struct AdItemListing {
        AdItemState state;
        address owner;
    }

    function listAdItem(address nftAddress, uint256 tokenId) external;

    function advertiseAdItem(
        address nftAddress,
        uint256 tokenId,
        uint256 fee
    ) external;
}
