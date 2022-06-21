## Contract to list, sell NFTs: NftMarketplace contract todo/notes
- try to come up with a better implementation of `state` in NftMarketplace; maybe use each 256 bits for one purpose and then use binary operators to extract the values
- add a functionality where a NFT can have different types, ex: an add, a post, a tiktok, etc

## contract to create nfts
- the off chain app will take the content and store it on a decentralized database (like IPFS). only the link  to the content will be passed to the contract to mint the nft

# EVM Compatible Smart Contracts 

This section includes a description of the smart contracts used in this project.

## Sociable NFT
A sociable NFT follows the ERC721 Non-Fungible Token Standard, including the Sociable extension. Sociable NFTs are to be listed and traded on the NFT Marketplace.

## NFT Marketplace

## ERC20 Token

## DAO

<!--

For an NFT of type advertisement:
- pay a certain amount of tokens to advertise something for a certain amount of time or a certain amount of views (certain amount of time would probably be easier to implement, could unlist the nft once a block number is reached)
- once the total number of views/time limit is reached, the nft becomes unlisted
- 

-->