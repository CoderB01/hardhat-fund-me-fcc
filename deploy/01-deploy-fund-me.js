const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { network } = require("hardhat")
const { verify } = require("../utils/verify")
require("dotenv").config()

// Pulling getNamedAccounts and deployments from hre
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    let ethToUsPriceFeedAddress

    // when going for localHost or hardhat network we want to  use a mock
    if (developmentChains.includes(network.name)) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethToUsPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethToUsPriceFeedAddress = networkConfig[chainId]["ethToUsPriceFeed"]
    }

    const args = [ethToUsPriceFeedAddress]

    const FundMe = await deploy("FundMe", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(FundMe.address, args)
    }
    log("--------------------------------------------------------")
}

module.exports.tags = ["all", "fundme"]
