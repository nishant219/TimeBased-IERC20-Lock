// const { ethers } = require("hardhat");

// async function main() {
//     const [deployer] = await ethers.getSigners();
//     console.log("Deploying contracts with the account:", deployer.address);
    
//     // Update the following line to use the correct contract factory
//     const HelloMeta = await ethers.getContractFactory(
//         "Hello MetaCoin",
//         "HMC",
//         7,
//         deployer.address 
//     );
    
//     const helloMeta = await HelloMeta.deploy();
//     console.log("HelloMeta address:", helloMeta.address);

//     // const initialOwner = '0x6eaD8B918f4f8E86d7D3AEAc19db7AC79aD5e5fb';
//     // const HelloMetaAddress=await ethers.getContractFactory("HelloMeta");
//     // const deployedHelloMeta=await HelloMetaAddress.deploy(
//     //     "Hello MetaCoin",
//     //     "HMC",
//     //     7,
//     //     initialOwner 
//     // ); 
//     // await deployedHelloMeta.deployed();
//     // console.log("HelloMeta deployed to (contract address):", deployedHelloMeta.address);
// }

// main()
//     .then(() => process.exit(0))
//     .catch(error => {
//         console.error(error);
//         process.exit(1);
//     });



const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const HelloMeta = await ethers.getContractFactory("HelloMeta");
    const futureTimestamp = Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 7; // Current timestamp + 7 days
    const helloMeta = await HelloMeta.deploy(futureTimestamp, deployer.address);

    // Access the contract's address directly
    console.log("HelloMeta address:", helloMeta.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
