// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./interfaces/INftBook.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error NftBook__NotApprovedForMarketplace();
error NftBook__ItemAlreadyListed(address nftAddress, uint256 tokenId);
error NftBook__NotOwner();
error NftBool__PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);

// error NftBook__NotListed(address nftAddress, uint256 tokenId);
// error NftBook__PriceNotMet(address nftAddress, uint256 tokenid, uint256 price);

contract NftBook is INftBook {
    //=====================================================================================
    //                                                                      state variables
    //=====================================================================================
    // NFT contract address -> NFT tokenId -> Listing (price and seller)
    mapping(address => mapping(uint256 => ItemListing)) private s_listings;

    // Seller address -> amount earned
    // mapping(address => uint256) private s_proceeds;

    //=====================================================================================
    //                                                                       main functions
    //=====================================================================================
    /// @inheritdoc INftBook
    function listItem(address nftAddress, uint256 tokenId) external override {
        ItemListing memory listing = ItemListing(address(0), msg.sender, 0, 1);
        _listItem(nftAddress, tokenId, listing);
    }

    /// @inheritdoc INftBook
    function listSalableItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external override {
        ItemListing memory listing = ItemListing(
            address(0),
            msg.sender,
            price,
            2
        );
        _listItem(nftAddress, tokenId, listing);
    }

    function _listItem(
        address nftAddress,
        uint256 tokenId,
        ItemListing memory listing
    ) internal {
        // reverts if the item is already listed
        uint256 state = s_listings[nftAddress][tokenId].state;
        if (state != 0) {
            revert NftBook__ItemAlreadyListed(nftAddress, tokenId);
        }
        // reverts if the msg.sender is not the owner of the item
        IERC721 nft = IERC721(nftAddress);
        if (listing.owner != nft.ownerOf(tokenId)) {
            revert NftBook__NotOwner();
        }
        // reverts if the NFT is salable and the owner has not approve this contract to transfer the NFT
        if ((state == 2) && (nft.getApproved(tokenId) != address(this))) {
            revert NftBook__NotApprovedForMarketplace();
        }

        s_listings[nftAddress][tokenId] = listing;
        emit ItemListed(listing.owner, nftAddress, tokenId, listing.price);
    }

    function unlistItem(address nftAddress, uint256 tokenId) external override {
        ItemListing memory listing = s_listings[nftAddress][tokenId];
        // reverts if the item is not listed
        if (listing.state == 0) {
            revert NftBook__ItemAlreadyListed(nftAddress, tokenId);
        }
        // reverts if the msg.sender is not the owner of the item
        IERC721 nft = IERC721(nftAddress);
        if (listing.owner != nft.ownerOf(tokenId)) {
            revert NftBook__NotOwner();
        }

        delete (s_listings[nftAddress][tokenId]);
        emit ItemUnlisted(listing.owner, nftAddress, tokenId);
    }

    function makeItemUnsalable(address nftAddress, uint256 tokenId)
        external
        override
    {
        ItemListing memory listing = s_listings[nftAddress][tokenId];
        // reverts if the item is not listed
        if (listing.state == 0) {
            revert NftBook__ItemAlreadyListed(nftAddress, tokenId);
        }
        // reverts if the msg.sender is not the owner of the item
        IERC721 nft = IERC721(nftAddress);
        if (listing.owner != nft.ownerOf(tokenId)) {
            revert NftBook__NotOwner();
        }

        s_listings[nftAddress][tokenId].state = 1;
    }

    /// @notice
    function makeItemSalable(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external override {
        ItemListing memory listing = s_listings[nftAddress][tokenId];
        // reverts if the item is not listed
        if (listing.state == 0) {
            revert NftBook__ItemAlreadyListed(nftAddress, tokenId);
        }
        // reverts if the msg.sender is not the owner of the item
        IERC721 nft = IERC721(nftAddress);
        if (listing.owner != nft.ownerOf(tokenId)) {
            revert NftBook__NotOwner();
        }

        listing.state = 2;
        listing.price = price;
        s_listings[nftAddress][tokenId] = listing;
    }

    /// @notice
    function buyItem(address nftAddress, uint256 tokenId)
        external
        payable
        override
    {
        ItemListing memory listing = s_listings[nftAddress][tokenId];
        // reverts if the item is not listed
        if (listing.state == 0) {
            revert NftBook__ItemAlreadyListed(nftAddress, tokenId);
        }
        // reverts if not enough funds transferred
        if (msg.value < listing.price) {
            revert NftBool__PriceNotMet(nftAddress, tokenId, listing.price);
        }

        address seller = listing.owner;
        listing.state = 1;
        listing.owner = msg.sender;
        s_listings[nftAddress][tokenId] = listing;

        IERC721(nftAddress).safeTransferFrom(seller, listing.owner, tokenId);
        emit ItemBought(listing.owner, nftAddress, tokenId, listing.price);
    }
}

/* notes:
    - if lists an nft with a price of 0, must have a way to modify the price
    - when sells an nft only appears on the creator and owner's account
*/
