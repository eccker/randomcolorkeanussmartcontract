require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    ropsten2: {
      url: "https://ropsten.infura.io/v3/7fc8b1e024424a7da9f920edac1b416e",
      accounts:
        process.env.ACCOUNT_KEY !== undefined ? [process.env.ACCOUNT_KEY] : [],
    },
    mumbai: {
      url: "https://polygon-mumbai.infura.io/v3/7fc8b1e024424a7da9f920edac1b416e",
      accounts:
        process.env.ACCOUNT_KEY !== undefined ? [process.env.ACCOUNT_KEY] : [],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
