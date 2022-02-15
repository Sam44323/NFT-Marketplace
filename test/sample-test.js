const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Marketplace", function () {
  it("Should create and execute sales on the marketplace", async function () {
    const [_, buyer] = await ethers.getSigners();
    const Marketplace = await ethers.getContractFactory("Marketplace");
    const marketplace = await Marketplace.deploy();
    await marketplace.deployed();
    const marketplaceAddress = marketplace.address;

    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketplaceAddress);
    await nft.deployed();
    const nftContractAddress = nft.address;

    const auctionPrice = ethers.utils.parseUnits("100", "ether");

    let listingPrice = await marketplace.getListingPrice();
    listingPrice = listingPrice.toString();

    await nft.createToken("https://www.minions.com");
    await nft.createToken("https://www.minions1.com");

    await marketplace.createMarketItem(nftContractAddress, 1, auctionPrice, {
      value: listingPrice,
    });
    await marketplace.createMarketItem(nftContractAddress, 2, auctionPrice, {
      value: listingPrice,
    });

    await marketplace.connect(buyer).createMarketSale(nftContractAddress, 1, {
      value: auctionPrice,
    });

    const items = await marketplace.fetchMarketItems();
    console.log("Items: ", items);

    expect(items.length).to.be.equal(1);
  });
});
