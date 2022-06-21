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
    const NftMarketplace = await deploy("NftMarketplace", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    });

    if (!isDevelopmentChain && process.env.ETHERSCAN_API_KEY) {
        log("Verifying on Etherscan...");
        await verify(NftMarketplace.address, arguments);
    }

    log("=========================================================");
};

module.exports.tags = ["all", "marketplace"];
