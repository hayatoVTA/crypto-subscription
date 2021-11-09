// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
const { exportRevert, constants, time } = require('@openzeppelin/test-helpers')


const THIRTY_DAYS = time.duration.days(30);
const SIXTY_DAYS = time.duration.days(60);

describe("Subscription contract test round 1", async () => {
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

  beforeEach(async () => {
    const [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    const TestToken = await ethers.getContractFactory("Token");
    const testtoken = await TestToken.deploy("Test Token", "TT")
    const subscrContract = await ethers.getContractFactory("Subscription");
    const subsrc = await subscrContract.deploy();
    console.log("Contract Deployed")

    // subsrc.
  })



  // await subsrc.deployed();

  if("")

  // s

  console.log("Token deployed to:", subsrc.address);
})
