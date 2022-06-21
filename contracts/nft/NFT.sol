// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721URIStorage, Ownable {
    //=====================================================================================
    //                                                                                types
    //=====================================================================================
    // enums have a size of 8 bits => max 256 different values
    enum NFTType {
        NONE,
        POST,
        SHORT_VIDEO,
        MUSIC,
        VIDEO
    }

    event NFTMinted(
        address indexed minter,
        uint256 indexed tokenId,
        NFTType indexed nftType
    );

    // tokenId to nftType
    mapping(uint256 => NFTType) private s_tokenIdToNFTType;
    // tokenId to creator
    mapping(uint256 => address) private s_tokenIdToMinter;
    uint256 private s_mintFee;
    uint256 private s_tokenCounter;

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
    {}

    function mintNFT(string memory tokenURI, NFTType nftType) public payable {
        uint256 tokenId = ++s_tokenCounter;
        _safeMint(msg.sender, tokenId); // emits ERC721 Transfer(address(0), to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        s_tokenIdToNFTType[tokenId] = nftType;
        s_tokenIdToMinter[tokenId] = msg.sender;
    }

    function getNFTType(uint256 tokenId) public view returns (NFTType) {
        return s_tokenIdToNFTType[tokenId];
    }

    function getMintFee() public view returns (uint256) {
        return s_mintFee;
    }

    function getMinter(uint256 tokenId) public view returns (address) {
        return s_tokenIdToMinter[tokenId];
    }

    function setMintFee(uint256 mintFee) public onlyOwner {
        s_mintFee = mintFee;
    }
}
