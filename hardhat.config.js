require("@nomiclabs/hardhat-waffle");
require("dotenv").config("./env");

const projectId = process.env.local.NEXT_PUBLIC_PROJECT_ID;

module.exports = {
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${projectId}`,
    },
  },
  solidity: "0.8.4",
};
