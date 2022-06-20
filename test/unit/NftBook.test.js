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

      describe("listItem", function () {
        it("returns true is item if listed", async function () {
          const res = await nftBook.callStatic.listItem(
            basicNft.address,
            TOKEN_ID
          );
          assert(res);
        });
        it("emits an event after listing an item", async function () {
          const tx = await nftBook.listItem(basicNft.address, TOKEN_ID);
          expect(tx).to.emit("ItemListed");
        });
      });
    });
