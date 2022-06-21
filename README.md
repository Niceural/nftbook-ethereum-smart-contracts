## Contract to list, sell NFTs: NftBook contract todo/notes
- try to come up with a better implementation of `state` in NftBook; maybe use each 256 bits for one purpose and then use binary operators to extract the values
- add a functionality where a NFT can have different types, ex: an add, a post, a tiktok, etc

## contract to create nfts
- the off chain app will take the content and store it on a decentralized database (like IPFS). only the link  to the content will be passed to the contract to mint the nft