// yarn add --dev dotenv
// https://chainlist.org to use to find chaid ID  or directly on the chain web site
// yarn add --dev solidity-coverage
// yarn hardhat coverage

require("@nomicfoundation/hardhat-toolbox")
require("dotenv").config() // tool to work with .env
require("@nomiclabs/hardhat-etherscan") // substitute for ethers but for hardhat
require("hardhat-gas-reporter") // tool to see how much gas spent
require("solidity-coverage")
require("hardhat-deploy") // deploy toolfor hard hat

const GOERLY_RPC_URL = process.env.GOERLY_RPC_URL || "" // || means OR. In other words if GOERLY_RPC_URL does not exist to use ""
const GOERLY_PRIVATE_KEY = process.env.GOERLY_PRIVATE_KEY
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || ""
const COINMARKET_API_KEY = process.env.COINMARKET_API_KEY

module.exports = {
    defaultNetwork: "hardhat",
    solidity: {
        compilers: [
            {
                version: "0.8.7",
            },
            {
                version: "0.6.6",
            },
        ],
    },

    networks: {
        // Networks for hardhat
        goerly: {
            url: GOERLY_RPC_URL,
            accounts: [GOERLY_PRIVATE_KEY],
            chainId: 5,
        },
        // hardhat evm resets after each execution
        // but we can run hardhat localhost node in a terminal which resets only with the terminal:
        localhost: {
            url: "http://127.0.0.1:8545/",
            chainId: 31337,
            // accounts are not needed, they are provided automatically
        },
    },
    etherscan: {
        // for smart ontract verification
        apiKey: ETHERSCAN_API_KEY,
    },
    solidity: {
        // for smart contracct verification by solidity-coverage
        compilers: [
            {
                version: "0.8.7",
            },
            {
                version: "0.6.6",
            },
        ],
    },
    mocha: {
        // i am not sure where it is used.
        timeout: 500000,
    },
    namedAccounts: {
        // For Hardhat-deploy
        deployer: {
            default: 0, // here this will by default take the first account as deployer
            1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
        },
    },

    gasReporter: {
        // we need to install gas reporter from npm: yarn add hardhat-gas-reporter --dev
        enabled: false,
        outputFile: "gas-report.txt",
        noColors: true,
        currency: "USD",
        coinmarketcap: COINMARKET_API_KEY, // coinmarketcap.com/api
        token: "MATIC",
    },
}
