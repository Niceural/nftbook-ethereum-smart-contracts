// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../nft/interfaces/IERC721Sociable.sol";
import "./interfaces/IAdvertisement.sol";
import "../token/interfaces/IERC20.sol";
import "../utils/Context.sol";

contract Advertisement is IAdvertisement, Context {
    address private s_nftContract;
    address private s_rewardContract;
    IERC20 private s_token;
    uint256 private s_adFeePerBlock;
    mapping(address => mapping(uint256 => AdItemListing)) s_adListings;

    //=====================================================================================
    //                                                                            modifiers
    //=====================================================================================
    modifier notListed(address nftAddress, uint256 tokenId) {
        _notListed(nftAddress, tokenId);
        _;
    }

    function _notListed(address nftAddress, uint256 tokenId) internal view {
        AdItemState state = s_adListings[nftAddress][tokenId].state;
        if (state != AdItemState.NOT_LISTED) {
            revert Advertisement__ItemAlreadyListed(nftAddress, tokenId);
        }
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        _isListed(nftAddress, tokenId);
        _;
    }

    function _isListed(address nftAddress, uint256 tokenId) internal view {
        AdItemState state = s_adListings[nftAddress][tokenId].state;
        if (state == AdItemState.NOT_LISTED) {
            revert Advertisement__ItemNotListed(nftAddress, tokenId);
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
        IERC721Sociable nft = IERC721Sociable(nftAddress);
        address owner = nft.ownerOf(tokenId);
        if (spender != owner) {
            revert Advertisement__NotOwner();
        }
    }

    constructor(
        address nftContract,
        address rewardContract,
        address tokenContract
    ) {
        s_nftContract = nftContract;
        s_rewardContract = rewardContract;
        s_token = IERC20(tokenContract);
    }

    function listAdItem(address nftAddress, uint256 tokenId)
        external
        override
        notListed(nftAddress, tokenId)
        isOwner(nftAddress, _msgSender(), tokenId)
    {
        if (nftAddress != s_nftContract)
            revert Advertisement__InvalidNftAddress();

        AdItemListing memory adItemListing = AdItemListing(
            AdItemState.LISTED,
            _msgSender()
        );
        s_adListings[nftAddress][tokenId] = adItemListing;
        emit AdItemListed(nftAddress, tokenId);
    }

    function advertiseAdItem(
        address nftAddress,
        uint256 tokenId,
        uint256 fee
    )
        external
        override
        isListed(nftAddress, tokenId)
        isOwner(nftAddress, _msgSender(), tokenId)
    {
        address owner = _msgSender();
        if (s_token.allowance(owner, address(this)) < fee) {
            revert Advertisement__InsufficientAmountAllowed();
        }

        s_token.transferFrom(owner, s_rewardContract, fee);
        s_adListings[nftAddress][tokenId].state = AdItemState.ADVERTISING;
        emit AdAdvertisementRequest(nftAddress, tokenId, fee);
    }
}
