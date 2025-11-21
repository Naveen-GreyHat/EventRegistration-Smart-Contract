const { ethers } = require("hardhat");

async function main() {
  console.log("🚀 Starting EventRegistration deployment...");

  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log(`📝 Deploying contract with account: ${deployer.address}`);

  // Get account balance (ethers v6 syntax)
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log(`💰 Account balance: ${ethers.formatEther(balance)} ETH`);

  // Deploy the contract
  const EventRegistration = await ethers.getContractFactory("EventRegistration");
  const eventRegistration = await EventRegistration.deploy();

  // Wait for deployment
  await eventRegistration.waitForDeployment();

  const contractAddress = await eventRegistration.getAddress();
  console.log(`✅ EventRegistration deployed to: ${contractAddress}`);

  // Show transaction hash (ethers v6 syntax)
  console.log(`🔗 Transaction hash: ${eventRegistration.deploymentTransaction().hash}`);

  // Example - Calling functions from contract
  const registrationFee = await eventRegistration.getRegistrationFee();
  console.log(`🎫 Registration fee: ${ethers.formatEther(registrationFee)} ETH`);

  const owner = await eventRegistration.owner();
  console.log(`👑 Contract owner: ${owner}`);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Deployment failed:", err);
    process.exit(1);
  });
