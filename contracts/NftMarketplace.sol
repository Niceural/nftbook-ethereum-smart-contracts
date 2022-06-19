// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// error NftMarketplace__PriceMustBePositive();
// error NftMarketplace__NotApprovedForMarketplace();
error NftMarketplace__ItemAlreadyListed(address nftAddress, uint256 tokenId);
error NftMarketplace__NotOwner();

// error NftMarketplace__NotListed(address nftAddress, uint256 tokenId);
// error NftMarketplace__PriceNotMet(address nftAddress, uint256 tokenid, uint256 price);

contract NftMarketplace {
    //=====================================================================================
    //                                                                                types
    //=====================================================================================
    struct Listing {
        address owner;
        address creator;
        bool isListed;
        uint256 price;
        bool canBeSold;
    }

    event ItemListed(
        address indexed owner,
        address indexed nftAddress,
        uint256 indexed tokenId,
        address creator
    );

    //=====================================================================================
    //                                                                      state variables
    //=====================================================================================
    // NFT contract address -> NFT tokenId -> Listing (price and seller)
    mapping(address => mapping(uint256 => Listing)) private s_listings;
    // Seller address -> amount earned
    // mapping(address => uint256) private s_proceeds;

    //=====================================================================================
    //                                                                            modifiers
    //=====================================================================================
    modifier notListed(address nftAddress, uint256 tokenId) {
        bool listed = s_listings[nftAddress][tokenId].isListed;
        if (listed) {
            revert NftMarketplace__ItemAlreadyListed(nftAddress, tokenId);
        }
        _;
    }
    modifier isOwner(
        address nftAddress,
        uint256 tokenId,
        address caller
    ) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (caller != owner) {
            revert NftMarketplace__NotOwner();
        }
        _;
    }

    /*modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        if (listing.isListed) {
            revert NftMarketplace__NotListed(nftAddress, tokenId);
        }
        _;
    }*/

    //=====================================================================================
    //                                                                       main functions
    //=====================================================================================
    /// @notice Method for listing an NFT on the marketplace
    /// @param nftAddress Address of the NFT Contract
    /// @param tokenId Token ID of NFT
    function listItem(address nftAddress, uint256 tokenId) external {
        _listItem(nftAddress, tokenId, msg.sender, address(0), 0, false);
        /*IERC721 nft = IERC721(nftAddress);
        s_listings[nftAddress][tokenId] = Listing(true, price, msg.sender, canBeSold);
        emit ItemListed(msg.sender, nftAddress, tokenId, price, canBeSold);*/
    }

    function _listItem(
        address nftAddress,
        uint256 tokenId,
        address owner,
        address creator,
        uint256 price,
        bool canBeSold
    ) internal notListed(nftAddress, tokenId) isOwner(nftAddress, tokenId, owner) {}

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
