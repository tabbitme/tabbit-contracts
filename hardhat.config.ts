import { HardhatUserConfig } from "hardhat/config";

// PLUGINS
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import { resolve} from 'path';
import * as glob from 'glob';
require('hardhat-contract-sizer');

// Process Env Variables
import * as dotenv from "dotenv";
dotenv.config({ path: __dirname + "/.env" });

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ALCHEMY_ID = process.env.ALCHEMY_ID;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY;

glob.sync('./tasks/**/*.ts').forEach(function (file: any) {
  require(resolve(file));
});

const config: HardhatUserConfig = {
  defaultNetwork: "mumbai",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      forking: {
        url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_ID}`
       // blockNumber: 7704180
      },
    },
    localhost: {
      url: 'http://localhost:8545',
      chainId: 31337,
    },
    goerli: {
      chainId: 5,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      gasPrice: 1000000000,
      url: `https://eth-goerli.api.onfinality.io/public`,
    },
    astar: {
      url: "https://1rpc.io/astr",
      chainId: 592,
      gasPrice: "auto",
      gasMultiplier: 2,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],

    },
    polygon: {
      chainId: 137,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      url: `https://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_ID}`,
    },
    mumbai: {
      url:`https://matic-mumbai.chainstacklabs.com`,
      chainId:80001,
      gasPrice: 10000000000,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
    },
    
  },

  solidity: {
    compilers: [
      {
        version: "0.8.9",
        settings: {
          optimizer: { enabled: true, runs: 200 },
        },
      },
    ],
  },
};

export default config;
