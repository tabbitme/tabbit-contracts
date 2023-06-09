// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  GiftCard = await ethers.getContractFactory("GiftCard");
  console.log("@Gift1");
  giftCard = await GiftCard.deploy();
  console.log("@Gift11");
  await giftCard.deployed();
  console.log("@Gift2");
  GiftCardAccount = await ethers.getContractFactory("GiftCardAccount");
  giftCardAccount = await GiftCardAccount.deploy();
  await giftCardAccount.deployed();

  console.log("@Gift3");
  ERC6551Registry = await ethers.getContractFactory("ERC6551Registry");
  erc6551Registry = await ERC6551Registry.deploy();
  await erc6551Registry.deployed();

  console.log("@Gift4");
  console.log("GiftCard contract deployed at:", giftCard.address);
  console.log("erc6551Registry contract deployed at:", erc6551Registry.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
