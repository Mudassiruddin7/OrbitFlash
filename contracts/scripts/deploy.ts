import { ethers } from "hardhat";

async function main() {
  // Arbitrum One Aave V3 Pool Addresses Provider
  const ARBITRUM_POOL_ADDRESSES_PROVIDER = "0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb";

  console.log("Deploying OrbitFlashArbitrage contract...");

  const OrbitFlashArbitrage = await ethers.getContractFactory("OrbitFlashArbitrage");
  const orbitFlashArbitrage = await OrbitFlashArbitrage.deploy(ARBITRUM_POOL_ADDRESSES_PROVIDER);

  await orbitFlashArbitrage.waitForDeployment();

  const contractAddress = await orbitFlashArbitrage.getAddress();
  console.log("OrbitFlashArbitrage deployed to:", contractAddress);

  // Verify deployment
  console.log("Verifying deployment...");
  const owner = await orbitFlashArbitrage.owner();
  console.log("Contract owner:", owner);

  const addressesProvider = await orbitFlashArbitrage.ADDRESSES_PROVIDER();
  console.log("Addresses provider:", addressesProvider);

  const pool = await orbitFlashArbitrage.POOL();
  console.log("Pool address:", pool);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
