/* eslint-disable no-process-exit */
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const linkToken = "0x326C977E6efc84E512bB9C30f76E30c160eD06FB";
  const vrfCoordinator = "0x8C7382F9D8f56b33781fE506E897a4F1e2d17255";
  const keyHash =
    "0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4";
  const fee = "100000000000000";
  const NFT = await hre.ethers.getContractFactory("NFT");
  const nft = await NFT.deploy(vrfCoordinator, linkToken, keyHash, fee);

  await nft.deployed();
  const nftContractAddress = nft.address;

  // const Token = await hre.ethers.getContractFactory("Token");
  // const ayekitoken = await Token.deploy("Ayekilua Token", "AYEKI");
  // await ayekitoken.deployed();
  // const tokenContractAddress = ayekitoken.address

  // console.log("market deployed to:", marketAddress);
  console.log("NFT deployed to:", nftContractAddress);
  // console.log("ayekitoken deployed to:", tokenContractAddress);
  // console.log("Stamper deployed to:", stamperAddress)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
