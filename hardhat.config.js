require('dotenv').config();
require("@nomicfoundation/hardhat-ethers");
require("@nomicfoundation/hardhat-verify");

// module.exports = {
//   solidity: "0.8.20", // Adjust the Solidity version as needed
// };

const {_RPC_URL,PRIVATE_KEY,ETHERSCAN_API_KEY} = process.env;
/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
    defaultNetwork: "holesky",
  solidity: {
  version: "0.8.24",
  settings: {
  optimizer: {
  enabled: true,
  runs: 200
    }
    }
    },
  networks: {
  holesky: {
  url: _RPC_URL,
  accounts: [`0x${PRIVATE_KEY}`]
    },
    },
  etherscan: {
  apiKey:{
  holesky: ETHERSCAN_API_KEY
    },
    },
  sourcify: {
  // Disabled by default
  // Doesn't need an API key
  enabled: true
    }
 
 
 };
 
