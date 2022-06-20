const { network } = require("hardhat");
const {
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
} = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const isDevelopmentChain = developmentChains.includes(network.name);
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const waitBlockConfirmations = isDevelopmentChain
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS;

    const arguments = [];
    const nftBook = await deploy("NftBook", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    });

    if (!isDevelopmentChain && process.env.ETHERSCAN_API_KEY) {
        log("Verifying on Etherscan...");
        await verify(nftBook.address, arguments);
    }

    log("=========================================================");
};

module.exports.tags = ["all", "nftbook"];
