const { assert, expect } = require("chai");
const { network, deployments, ethers } = require("hardhat");
const { developmentChains } = require("../../helper-hardhat-config");

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("Nft Book Unit Tests", function () {
      let cNftBook, nftBook, basicNft, cBasicNft;
      const PRICE = ethers.utils.parseEther("0.1");
      const TOKEN_ID = 0;

      beforeEach(async () => {
        accounts = await ethers.getSigners();
        deployer = accounts[0];
        user = accounts[1];

        await deployments.fixture(["all"]);
        cNftBook = await ethers.getContract("NftBook");
        nftBook = await cNftBook.connect(deployer);
        cBasicNft = await ethers.getContract("BasicNftOne");
        basicNft = await cBasicNft.connect(deployer);

        await basicNft.mintNft();
        await basicNft.approve(cNftBook.address, TOKEN_ID);
      });

      describe("listItem", function () {});

      describe("listSalableItem", function () {
        it("emits an event on listing", async function () {
          const tx = await nftBook.listSalableItem(
            basicNft.address,
            TOKEN_ID,
            PRICE
          );
          expect(tx).to.emit("ItemListed");
        });
        it("reverts if already listed", async function () {
          await nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE);
          const error = `NftBook__ItemAlreadyListed("${basicNft.address}", ${TOKEN_ID})`;
          await expect(
            nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE)
          ).to.be.revertedWith(error);
        });
        it("reverts if not owner", async function () {
          nftBook = cNftBook.connect(user);
          await basicNft.approve(user.address, TOKEN_ID);
          await expect(
            nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE)
          ).to.be.revertedWith("NftBook__NotOwner");
        });
        it("reverts if NFT Book is not approved to transfer the token", async function () {
          await basicNft.approve(ethers.constants.AddressZero, TOKEN_ID);
          await expect(
            nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE)
          ).to.be.revertedWith("NftBook__NotApprovedForMarketplace");
        });
        it("sets the ItemListing correctly", async function () {
          await nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE);
          const listing = await nftBook.getItemListing(
            basicNft.address,
            TOKEN_ID
          );
          assert.equal(listing.owner.toString(), deployer.address);
          assert.equal(listing.minPrice.toString(), PRICE.toString());
          assert.equal(listing.state.toString(), "2");
        });
        it("sets price to 0 for a negative price entered", async function () {});
        it("sets price to max uint256 for a price larger than max uint256", async function () {});
      });

      describe("cancelItem", function () {
        it("reverts if not owner", async function () {});
        it("reverts if not listed", async function () {});
        it("emits an event when item is canceled", async function () {});
        it("correctly modifier the state of the NFT", async function () {});
      });

      describe("makeItemUnsalable", function () {});

      describe("makeItemSalable", function () {});

      describe("buyItem", function () {});
    });
