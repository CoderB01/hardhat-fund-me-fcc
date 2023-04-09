const { isAddress } = require("ethers/lib/utils")
const { getNamedAccounts, ethers } = require("hardhat")

async function main() {
    const { deployer } = await getNamedAccounts()
    const fundMe = await ethers.getContract("FundMe", deployer)

    console.log("Funding...........................")
    const transactionResponse = await fundMe.withdraw()

    await transactionResponse.wait(1)

    console.log("Got it out!")
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
