import { expect } from "chai";
import { ethers } from "hardhat";
import { OrbitFlashArbitrage } from "../typechain-types";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

describe("OrbitFlashArbitrage", function () {
  let orbitFlashArbitrage: OrbitFlashArbitrage;
  let owner: SignerWithAddress;
  let addr1: SignerWithAddress;

  // Arbitrum One addresses
  const ARBITRUM_POOL_ADDRESSES_PROVIDER = "0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb";
  const WETH_ADDRESS = "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1";
  const USDC_ADDRESS = "0xA0b86a33E6441b8435b662303c0f479c0c5c8b3E";

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();

    const OrbitFlashArbitrage = await ethers.getContractFactory("OrbitFlashArbitrage");
    orbitFlashArbitrage = await OrbitFlashArbitrage.deploy(ARBITRUM_POOL_ADDRESSES_PROVIDER);
    await orbitFlashArbitrage.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await orbitFlashArbitrage.owner()).to.equal(owner.address);
    });

    it("Should set the correct addresses provider", async function () {
      expect(await orbitFlashArbitrage.ADDRESSES_PROVIDER()).to.equal(ARBITRUM_POOL_ADDRESSES_PROVIDER);
    });

    it("Should initialize the pool address", async function () {
      const poolAddress = await orbitFlashArbitrage.POOL();
      expect(poolAddress).to.not.equal(ethers.ZeroAddress);
    });
  });

  describe("Access Control", function () {
    it("Should only allow owner to execute arbitrage", async function () {
      const arbitrageParams = {
        tokenIn: WETH_ADDRESS,
        tokenOut: USDC_ADDRESS,
        amountIn: ethers.parseEther("1"),
        minProfit: ethers.parseEther("0.01"),
        dexAddresses: [WETH_ADDRESS], // Dummy address
        swapCalldata: ["0x"]
      };

      await expect(
        orbitFlashArbitrage.connect(addr1).executeArbitrage(arbitrageParams)
      ).to.be.revertedWithCustomError(orbitFlashArbitrage, "OwnableUnauthorizedAccount");
    });
  });

  describe("Parameter Validation", function () {
    it("Should reject invalid tokenIn", async function () {
      const arbitrageParams = {
        tokenIn: ethers.ZeroAddress,
        tokenOut: USDC_ADDRESS,
        amountIn: ethers.parseEther("1"),
        minProfit: ethers.parseEther("0.01"),
        dexAddresses: [WETH_ADDRESS],
        swapCalldata: ["0x"]
      };

      await expect(
        orbitFlashArbitrage.executeArbitrage(arbitrageParams)
      ).to.be.revertedWith("Invalid tokenIn");
    });

    it("Should reject invalid tokenOut", async function () {
      const arbitrageParams = {
        tokenIn: WETH_ADDRESS,
        tokenOut: ethers.ZeroAddress,
        amountIn: ethers.parseEther("1"),
        minProfit: ethers.parseEther("0.01"),
        dexAddresses: [WETH_ADDRESS],
        swapCalldata: ["0x"]
      };

      await expect(
        orbitFlashArbitrage.executeArbitrage(arbitrageParams)
      ).to.be.revertedWith("Invalid tokenOut");
    });

    it("Should reject zero amountIn", async function () {
      const arbitrageParams = {
        tokenIn: WETH_ADDRESS,
        tokenOut: USDC_ADDRESS,
        amountIn: 0,
        minProfit: ethers.parseEther("0.01"),
        dexAddresses: [WETH_ADDRESS],
        swapCalldata: ["0x"]
      };

      await expect(
        orbitFlashArbitrage.executeArbitrage(arbitrageParams)
      ).to.be.revertedWith("Invalid amountIn");
    });

    it("Should reject empty DEX addresses", async function () {
      const arbitrageParams = {
        tokenIn: WETH_ADDRESS,
        tokenOut: USDC_ADDRESS,
        amountIn: ethers.parseEther("1"),
        minProfit: ethers.parseEther("0.01"),
        dexAddresses: [],
        swapCalldata: []
      };

      await expect(
        orbitFlashArbitrage.executeArbitrage(arbitrageParams)
      ).to.be.revertedWith("No DEX addresses");
    });

    it("Should reject mismatched arrays", async function () {
      const arbitrageParams = {
        tokenIn: WETH_ADDRESS,
        tokenOut: USDC_ADDRESS,
        amountIn: ethers.parseEther("1"),
        minProfit: ethers.parseEther("0.01"),
        dexAddresses: [WETH_ADDRESS, USDC_ADDRESS],
        swapCalldata: ["0x"]
      };

      await expect(
        orbitFlashArbitrage.executeArbitrage(arbitrageParams)
      ).to.be.revertedWith("Mismatched arrays");
    });
  });

  describe("Utility Functions", function () {
    it("Should return token balance", async function () {
      const balance = await orbitFlashArbitrage.getTokenBalance(WETH_ADDRESS);
      expect(balance).to.equal(0);
    });

    it("Should check flash loan capability", async function () {
      const canExecute = await orbitFlashArbitrage.canExecuteFlashLoan(WETH_ADDRESS, ethers.parseEther("1"));
      expect(canExecute).to.be.a("boolean");
    });
  });

  describe("Emergency Functions", function () {
    it("Should only allow owner to emergency withdraw", async function () {
      await expect(
        orbitFlashArbitrage.connect(addr1).emergencyWithdraw(WETH_ADDRESS, ethers.parseEther("1"))
      ).to.be.revertedWithCustomError(orbitFlashArbitrage, "OwnableUnauthorizedAccount");
    });

    it("Should only allow owner to emergency withdraw all", async function () {
      await expect(
        orbitFlashArbitrage.connect(addr1).emergencyWithdrawAll(WETH_ADDRESS)
      ).to.be.revertedWithCustomError(orbitFlashArbitrage, "OwnableUnauthorizedAccount");
    });
  });

  describe("Ether Rejection", function () {
    it("Should reject direct Ether transfers", async function () {
      await expect(
        owner.sendTransaction({
          to: await orbitFlashArbitrage.getAddress(),
          value: ethers.parseEther("1")
        })
      ).to.be.revertedWith("Contract does not accept Ether");
    });
  });
});
