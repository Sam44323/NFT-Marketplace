require("@nomiclabs/hardhat-waffle");
const dotenv = require("dotenv");

dotenv.config();

module.exports = {
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: process.env.MUMBAI_ID,
    },
  },
  solidity: "0.8.4",
};
