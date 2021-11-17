require("@nomiclabs/hardhat-waffle");
require('dotenv').config();

const privateKey = process.env.DEPLOYER_SIGNER_PRIVATE_KEY;
const projectID = process.env.INFURA_PROJECT_ID;

module.exports = {
  solidity: "0.8.4",
  networks: {
    ropsten: {
      url: `https://ropsten.infura.io/v3/${projectID}`,
      accounts: [privateKey],
    }
  }
};
