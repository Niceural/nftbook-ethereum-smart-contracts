// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./interfaces/INftBook.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error NftMarketplace__NotApprovedForMarketplace();
error NftMarketplace__ItemAlreadyListed(address nftAddress, uint256 tokenId);
error NftMarketplace__NotOwner();

// error NftMarketplace__NotListed(address nftAddress, uint256 tokenId);
// error NftMarketplace__PriceNotMet(address nftAddress, uint256 tokenid, uint256 price);

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
    function listItem(address nftAddress, uint256 tokenId)
        external
        override
        returns (bool success)
    {
        ItemListing memory listing = ItemListing(
            address(0),
            msg.sender,
            0,
            true,
            false
        );
        _listItem(nftAddress, tokenId, listing);
        return true;
    }

    /// @inheritdoc INftBook
    function listSalableItem(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) external override returns (bool success) {
        ItemListing memory listing = ItemListing(
            address(0),
            msg.sender,
            price,
            true,
            true
        );
        _listItem(nftAddress, tokenId, listing);
        return true;
    }

    function _listItem(
        address nftAddress,
        uint256 tokenId,
        ItemListing memory listing
    ) internal {
        // reverts if the item is already listed
        bool listed = s_listings[nftAddress][tokenId].isListed;
        if (listed) {
            revert NftMarketplace__ItemAlreadyListed(nftAddress, tokenId);
        }
        // reverts if the msg.sender is not the owner of the item
        IERC721 nft = IERC721(nftAddress);
        if (listing.owner != nft.ownerOf(tokenId)) {
            revert NftMarketplace__NotOwner();
        }
        // reverts if the NFT is salable and the owner has not approve this contract to transfer the NFT
        if (
            (listing.isSalable) && (nft.getApproved(tokenId) != address(this))
        ) {
            revert NftMarketplace__NotApprovedForMarketplace();
        }

        s_listings[nftAddress][tokenId] = listing;
        emit ItemListed(listing.owner, nftAddress, tokenId, listing.price);
    }

    /*function buyItem(address nftAddress, uint256 tokenId)
        external
        payable
        isListed(nftAddress, tokenId)
    {
        Listing memory listedItem = s_listings[nftAddress][tokenId];
        if (msg.value < listedItem.price) {
            revert NftMarketplace__PriceNotMet(nftAddress, tokenId, listedItem.price);
        }

        s_proceeds[listedItem.seller] += msg.value;
        delete (s_listings[nftAddress][tokenId]);
        IERC721(nftAddress).transferFrom(listedItem.seller, msg.sender, tokenId);
    }*/
}

/* notes:
    - if lists an nft with a price of 0, must have a way to modify the price
    - when sells an nft only appears on the creator and owner's account
*/
