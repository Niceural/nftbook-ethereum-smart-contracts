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
    const basicNftOne = await deploy("BasicNftOne", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    });

    const basicNftTwo = await deploy("BasicNftTwo", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: waitBlockConfirmations,
    });

    if (!isDevelopmentChain && process.env.ETHERSCAN_API_KEY) {
        log("Verifying on Etherscan...");
        await verify(basicNftOne.address, args);
        await verify(basicNftTwo.address, args);
    }
};

module.exports.tags = ["all", "basicnft"];
