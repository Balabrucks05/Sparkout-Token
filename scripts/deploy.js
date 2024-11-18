const {ethers} = require("hardhat");

async function main(){
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contractrs with the account:", deployer.address);
    const SparkoutToken = await ethers.getContractFactory("SparkoutToken");
    const sparkoutToken_= await SparkoutToken.deploy();
    const SparkoutTokenAddress = await sparkoutToken_.getAddress();
        console.log(`SparkToken deployed to: ${SparkoutTokenAddress}`)
}



main().catch((error) => {
    console.error(error);
    process.exitcode = 1;
})
