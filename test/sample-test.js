// const { expect } = require("chai");

describe("NFTMarket", function () {
  it("Should create and execute market sells", async function () {
    const Market = await ethers.getContractFactory("NFTMarket");
    const market = await Market.deploy();
    await market.deployed();
    const marketAddress = market.address;

    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed();
    const nftContractAddress = nft.address;

    // const Token = await hre.ethers.getContractFactory("Token");
    // const ayekistoken = await Token.deploy("Ayekilua Token", "AYEKIS");

    let listingPrice = await market.getListingPrice();
    listingPrice = listingPrice.toString();

    const auctionPrice = ethers.utils.parseUnits("100", "ether");
    const auctionPrice4 = ethers.utils.parseUnits("400", "ether");

    let id1 = await nft.createSVGNFT("_svg1");
    // console.log(id1.data)
    let id2 = await nft.createSVGNFT("_svg2");
    let id3 = await nft.createSVGNFT("_svg3");
    let id4 = await nft.createSVGNFT("_svg4");
    let id5 = await nft.createSVGNFT("_svg5");

    await market.createMarketItem(nftContractAddress, 1, auctionPrice, {
      value: listingPrice,
    });
    await market.createMarketItem(nftContractAddress, 2, auctionPrice, {
      value: listingPrice,
    });
    await market.createMarketItem(nftContractAddress, 3, auctionPrice, {
      value: listingPrice,
    });
    await market.createMarketItem(nftContractAddress, 4, auctionPrice4, {
      value: listingPrice,
    });
    await market.createMarketItem(nftContractAddress, 5, auctionPrice, {
      value: listingPrice,
    });

    const [_, buyerAddress] = await ethers.getSigners();

    await market.connect(buyerAddress).createMarketSale(nftContractAddress, 4, {
      value: auctionPrice4,
    });

    let items = await market.fetchMarketItems();

    items = await Promise.all(
      items.map(async (i) => {
        const tokenUri = await nft.tokenURI(i.tokenId);
        let item = {
          price: i.price.toString(),
          tokenId: i.tokenId.toString(),
          seller: i.seller,
          owner: i.owner,
          tokenUri,
        };
        return item;
      })
    );

    console.log("items: ", items);

    let myitems = await market.fetchItemsCreated();

    myitems = await Promise.all(
      myitems.map(async (i) => {
        const tokenUri = await nft.tokenURI(i.tokenId);
        let item = {
          price: i.price.toString(),
          tokenId: i.tokenId.toString(),
          seller: i.seller,
          owner: i.owner,
          tokenUri,
        };
        return item;
      })
    );

    console.log("myitems: ", myitems);
  });
});
