// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./interfaces/INftBook.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error NftBook__NotApprovedForMarketplace();
error NftBook__ItemAlreadyListed(address nftAddress, uint256 tokenId);
error NftBook__NotOwner();
error NftBook__PriceNotMet(
    address nftAddress,
    uint256 tokenId,
    uint256 minPrice
);
error NftBook__NoProceeds();
error NftBook__ItemNotListed(address nftAddress, uint256 tokenId);

contract NftBook is INftBook {
    //=====================================================================================
    //                                                                      state variables
    //=====================================================================================
    // NFT contract address -> NFT tokenId -> INftBook.ItemListing
    mapping(address => mapping(uint256 => ItemListing)) private s_listings;
    // Seller address -> amount earned
    mapping(address => uint256) private s_proceeds;

    //=====================================================================================
    //                                                                            modifiers
    //=====================================================================================
    modifier notListed(address nftAddress, uint256 tokenId) {
        _notListed(nftAddress, tokenId);
        _;
    }

    function _notListed(address nftAddress, uint256 tokenId) internal view {
        uint256 state = s_listings[nftAddress][tokenId].state;
        if (state != 0) {
            revert NftBook__ItemAlreadyListed(nftAddress, tokenId);
        }
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        _isListed(nftAddress, tokenId);
        _;
    }

    function _isListed(address nftAddress, uint256 tokenId) internal view {
        uint256 state = s_listings[nftAddress][tokenId].state;
        if (state == 0) {
            revert NftBook__ItemNotListed(nftAddress, tokenId);
        }
    }

    modifier isOwner(
        address nftAddress,
        address spender,
        uint256 tokenId
    ) {
        _isOwner(nftAddress, spender, tokenId);
        _;
    }

    function _isOwner(
        address nftAddress,
        address spender,
        uint256 tokenId
    ) internal view {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert NftBook__NotOwner();
        }
    }

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
        uint256 minPrice
    ) external override {
        ItemListing memory listing = ItemListing(
            address(0),
            msg.sender,
            minPrice,
            2
        );
        _listItem(nftAddress, tokenId, listing);
    }

    function _listItem(
        address nftAddress,
        uint256 tokenId,
        ItemListing memory listing
    )
        internal
        notListed(nftAddress, tokenId)
        isOwner(nftAddress, msg.sender, tokenId)
    {
        // reverts if the NFT is salable and the owner has not approve this contract to transfer the NFT
        IERC721 nft = IERC721(nftAddress);
        if (
            (listing.state == 2) && (nft.getApproved(tokenId) != address(this))
        ) {
            revert NftBook__NotApprovedForMarketplace();
        }

        s_listings[nftAddress][tokenId] = listing;
        emit ItemListed(
            listing.owner,
            nftAddress,
            tokenId,
            listing.minPrice,
            listing.state
        );
    }

    function cancelItemListing(address nftAddress, uint256 tokenId)
        external
        override
        isListed(nftAddress, tokenId)
        isOwner(nftAddress, msg.sender, tokenId)
    {
        delete (s_listings[nftAddress][tokenId]);
        emit ItemListingCanceled(msg.sender, nftAddress, tokenId);
    }

    function makeItemUnsalable(address nftAddress, uint256 tokenId)
        external
        override
        isListed(nftAddress, tokenId)
        isOwner(nftAddress, msg.sender, tokenId)
    {
        s_listings[nftAddress][tokenId].state = 1;
        emit ItemListed(msg.sender, nftAddress, tokenId, 0, 1);
    }

    /// @notice
    function makeItemSalable(
        address nftAddress,
        uint256 tokenId,
        uint256 minPrice
    )
        external
        override
        isListed(nftAddress, tokenId)
        isOwner(nftAddress, msg.sender, tokenId)
    {
        ItemListing memory listing = s_listings[nftAddress][tokenId];
        // reverts if the NFT is salable and the owner has not approve this contract to transfer the NFT
        IERC721 nft = IERC721(nftAddress);
        if (nft.getApproved(tokenId) != address(this)) {
            revert NftBook__NotApprovedForMarketplace();
        }

        listing.state = 2;
        listing.minPrice = minPrice;
        s_listings[nftAddress][tokenId] = listing;
        emit ItemListed(
            msg.sender,
            nftAddress,
            tokenId,
            listing.minPrice,
            listing.state
        );
    }

    /// @notice
    // pb with proceeds
    function buyItem(address nftAddress, uint256 tokenId)
        external
        payable
        override
        isListed(nftAddress, tokenId)
    {
        ItemListing memory listing = s_listings[nftAddress][tokenId];
        // reverts if not enough funds transferred
        if (msg.value < listing.minPrice) {
            revert NftBook__PriceNotMet(nftAddress, tokenId, listing.minPrice);
        }

        s_proceeds[listing.owner] += msg.value;
        address seller = listing.owner;
        listing.state = 1;
        listing.owner = msg.sender;
        s_listings[nftAddress][tokenId] = listing;

        IERC721(nftAddress).safeTransferFrom(seller, listing.owner, tokenId);
        emit ItemBought(listing.owner, nftAddress, tokenId, listing.minPrice);
    }

    function withdrawProceeds() external override {
        uint256 proceeds = s_proceeds[msg.sender];
        if (proceeds <= 0) {
            revert NftBook__NoProceeds();
        }

        s_proceeds[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: proceeds}("");
        require(success, "Transfer failed");
    }

    function getItemListing(address nftAddress, uint256 tokenId)
        external
        view
        override
        returns (ItemListing memory)
    {
        return s_listings[nftAddress][tokenId];
    }

    function getProceeds(address seller)
        external
        view
        override
        returns (uint256)
    {
        return s_proceeds[seller];
    }
}

/* notes:
    - if lists an nft with a minPrice of 0, must have a way to modify the minPrice
    - when sells an nft only appears on the creator and owner's account
*/
