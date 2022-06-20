const { assert, expect } = require("chai");
const { network, deployments, ethers } = require("hardhat");
const { developmentChains } = require("../../helper-hardhat-config");

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("Nft Book Unit Tests", function () {
      let cNftBook, nftBook, basicNft, cBasicNft;
      const PRICE = ethers.utils.parseEther("0.1");
      const NEW_PRICE = ethers.utils.parseEther("0.2");
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

      describe("listItem", function () {
        it("emits an event on listing", async function () {
          const tx = await nftBook.listItem(basicNft.address, TOKEN_ID);
          expect(tx).to.emit("ItemListed");
        });
        it("reverts if already listed", async function () {
          await nftBook.listItem(basicNft.address, TOKEN_ID);
          const error = `NftBook__ItemAlreadyListed("${basicNft.address}", ${TOKEN_ID})`;
          await expect(
            nftBook.listItem(basicNft.address, TOKEN_ID)
          ).to.be.revertedWith(error);
        });
        it("reverts if not owner", async function () {
          nftBook = cNftBook.connect(user);
          await basicNft.approve(user.address, TOKEN_ID);
          await expect(
            nftBook.listItem(basicNft.address, TOKEN_ID)
          ).to.be.revertedWith("NftBook__NotOwner");
        });
        it("sets the ItemListing correctly", async function () {
          await nftBook.listItem(basicNft.address, TOKEN_ID);
          const listing = await nftBook.getItemListing(
            basicNft.address,
            TOKEN_ID
          );
          assert.equal(listing.owner.toString(), deployer.address);
          assert.equal(listing.minPrice.toString(), "0");
          assert.equal(listing.state.toString(), "1");
        });
      });

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
      });

      describe("cancelItemListing", function () {
        it("reverts if caller is not the owner", async function () {
          await nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE);
          nftBook = cNftBook.connect(user);
          await basicNft.approve(user.address, TOKEN_ID);
          await expect(
            nftBook.cancelItemListing(basicNft.address, TOKEN_ID)
          ).to.be.revertedWith("NftBook__NotOwner");
        });
        it("reverts if item is not listed", async function () {
          const error = `NftBook__ItemNotListed("${basicNft.address}", ${TOKEN_ID})`;
          await expect(
            nftBook.cancelItemListing(basicNft.address, TOKEN_ID)
          ).to.be.revertedWith(error);
        });
        it("emits an event when item is canceled", async function () {
          await nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE);
          expect(
            await nftBook.cancelItemListing(basicNft.address, TOKEN_ID)
          ).to.emit("ItemListingCanceled");
        });
        it("correctly sets the ItemListing", async function () {
          await nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE);
          await nftBook.cancelItemListing(basicNft.address, TOKEN_ID);
          const listing = await nftBook.getItemListing(
            basicNft.address,
            TOKEN_ID
          );
          assert.equal(
            listing.creator.toString(),
            ethers.constants.AddressZero
          );
          assert.equal(listing.owner.toString(), ethers.constants.AddressZero);
          assert.equal(listing.minPrice.toString(), "0");
          assert.equal(listing.state.toString(), "0");
        });
      });

      describe("makeItemUnsalable", function () {
        it("reverts if caller is not the owner", async function () {
          await nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE);
          nftBook = cNftBook.connect(user);
          await basicNft.approve(user.address, TOKEN_ID);
          await expect(
            nftBook.makeItemUnsalable(basicNft.address, TOKEN_ID)
          ).to.be.revertedWith("NftBook__NotOwner");
        });
        it("reverts if item is not listed", async function () {
          const error = `NftBook__ItemNotListed("${basicNft.address}", ${TOKEN_ID})`;
          await expect(
            nftBook.makeItemUnsalable(basicNft.address, TOKEN_ID)
          ).to.be.revertedWith(error);
        });
        it("emits an ItemListed event", async function () {
          await nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE);
          expect(
            await nftBook.makeItemUnsalable(basicNft.address, TOKEN_ID)
          ).to.emit("ItemListed");
        });
        it("correctly modifies the ItemListing", async function () {
          await nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE);
          await nftBook.makeItemUnsalable(basicNft.address, TOKEN_ID);
          const listing = await nftBook.getItemListing(
            basicNft.address,
            TOKEN_ID
          );
          assert.equal(listing.state.toString(), "1");
        });
      });

      describe("makeItemSalable", function () {
        it("reverts if caller is not the owner", async function () {
          await nftBook.listItem(basicNft.address, TOKEN_ID);
          nftBook = cNftBook.connect(user);
          await basicNft.approve(user.address, TOKEN_ID);
          await expect(
            nftBook.makeItemSalable(basicNft.address, TOKEN_ID, NEW_PRICE)
          ).to.be.revertedWith("NftBook__NotOwner");
        });
        it("reverts if item is not listed", async function () {
          const error = `NftBook__ItemNotListed("${basicNft.address}", ${TOKEN_ID})`;
          await expect(
            nftBook.makeItemSalable(basicNft.address, TOKEN_ID, NEW_PRICE)
          ).to.be.revertedWith(error);
        });
        it("reverts if NFT Book is not approved to transfer the token", async function () {
          await basicNft.approve(ethers.constants.AddressZero, TOKEN_ID);
          await nftBook.listItem(basicNft.address, TOKEN_ID);
          await expect(
            nftBook.makeItemSalable(basicNft.address, TOKEN_ID, NEW_PRICE)
          ).to.be.revertedWith("NftBook__NotApprovedForMarketplace");
        });
        it("emits an ItemListed event", async function () {
          await nftBook.listItem(basicNft.address, TOKEN_ID);
          expect(
            await nftBook.makeItemSalable(basicNft.address, TOKEN_ID, NEW_PRICE)
          ).to.emit("ItemListed");
        });
        it("correctly modifies the ItemListing", async function () {
          await nftBook.listItem(basicNft.address, TOKEN_ID);
          await nftBook.makeItemSalable(basicNft.address, TOKEN_ID, NEW_PRICE);
          const listing = await nftBook.getItemListing(
            basicNft.address,
            TOKEN_ID
          );
          assert.equal(listing.state.toString(), "2");
          assert.equal(listing.minPrice.toString(), NEW_PRICE.toString());
        });
      });

      describe("buyItem", function () {
        it("reverts if item is not listed", async function () {
          const error = `NftBook__ItemNotListed("${basicNft.address}", ${TOKEN_ID})`;
          await expect(
            nftBook.buyItem(basicNft.address, TOKEN_ID)
          ).to.be.revertedWith(error);
        });
        it("reverts if not enough funds are sent", async function () {
          const error = `NftBook__PriceNotMet("${basicNft.address}", ${TOKEN_ID}, ${PRICE})`;
          await nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE);
          await expect(
            nftBook.buyItem(basicNft.address, TOKEN_ID)
          ).to.be.revertedWith(error);
        });
        it("emits a ERC721 Transfer event", async function () {
          await nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE);
          nftBook = cNftBook.connect(user);
          expect(
            await nftBook.buyItem(basicNft.address, TOKEN_ID, { value: PRICE })
          ).to.emit("Transfer");
        });
        it("emits an ItemBought event", async function () {
          await nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE);
          nftBook = cNftBook.connect(user);
          expect(
            await nftBook.buyItem(basicNft.address, TOKEN_ID, { value: PRICE })
          ).to.emit("ItemBought");
        });
        it("correctly modifies the ItemListing", async function () {
          await nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE);
          nftBook = cNftBook.connect(user);
          await nftBook.buyItem(basicNft.address, TOKEN_ID, { value: PRICE });
          const listing = await nftBook.getItemListing(
            basicNft.address,
            TOKEN_ID
          );
          assert.equal(listing.state.toString(), "1");
          assert.equal(listing.owner.toString(), user.address);
        });
        it("sets the proceeds to the correct value", async function () {
          const proceedsBefore = await ethers.BigNumber.from(
            nftBook.getProceeds(deployer.address)
          );
          await nftBook.listSalableItem(basicNft.address, TOKEN_ID, PRICE);
          nftBook = cNftBook.connect(user);
          await nftBook.buyItem(basicNft.address, TOKEN_ID, { value: PRICE });
          const proceedsAfter = await ethers.BigNumber.from(
            nftBook.getProceeds(deployer.address)
          );
          const expectedProceeds = proceedsBefore.add(PRICE);
          assert.equal(proceedsAfter, expectedProceeds);
        });
      });

      describe("withdrawProceeds", function () {
        it("reverts if proceeds is 0", async function () {});
        it("sets the proceeds to 0 just before transfer", async function () {});
      });
    });
