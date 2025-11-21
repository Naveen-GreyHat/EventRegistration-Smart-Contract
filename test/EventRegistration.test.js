const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EventRegistration", function () {
  let EventRegistration;
  let eventRegistration;
  let owner;
  let attendee1;
  let attendee2;

  const REGISTRATION_FEE = ethers.utils.parseEther("0.01");

  beforeEach(async function () {
    [owner, attendee1, attendee2] = await ethers.getSigners();
    
    EventRegistration = await ethers.getContractFactory("EventRegistration");
    eventRegistration = await EventRegistration.deploy();
    await eventRegistration.deployed();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await eventRegistration.owner()).to.equal(owner.address);
    });

    it("Should have correct registration fee", async function () {
      expect(await eventRegistration.getRegistrationFee()).to.equal(REGISTRATION_FEE);
    });

    it("Should start with 0 participants", async function () {
      expect(await eventRegistration.getParticipantCount()).to.equal(0);
    });
  });

  describe("Registration", function () {
    it("Should allow registration with correct fee", async function () {
      await expect(
        eventRegistration.connect(attendee1).register({ value: REGISTRATION_FEE })
      )
        .to.emit(eventRegistration, "Registered")
        .withArgs(attendee1.address, expect.any(Number));

      expect(await eventRegistration.isRegistered(attendee1.address)).to.be.true;
      expect(await eventRegistration.getParticipantCount()).to.equal(1);
    });

    it("Should fail with incorrect fee", async function () {
      await expect(
        eventRegistration.connect(attendee1).register({ value: ethers.utils.parseEther("0.005") })
      ).to.be.revertedWith("EventRegistration: Incorrect payment amount. Required: 0.01 ETH");

      await expect(
        eventRegistration.connect(attendee1).register({ value: ethers.utils.parseEther("0.02") })
      ).to.be.revertedWith("EventRegistration: Incorrect payment amount. Required: 0.01 ETH");
    });

    it("Should prevent double registration", async function () {
      await eventRegistration.connect(attendee1).register({ value: REGISTRATION_FEE });
      
      await expect(
        eventRegistration.connect(attendee1).register({ value: REGISTRATION_FEE })
      ).to.be.revertedWith("EventRegistration: Address already registered");
    });

    it("Should track multiple registrations correctly", async function () {
      await eventRegistration.connect(attendee1).register({ value: REGISTRATION_FEE });
      await eventRegistration.connect(attendee2).register({ value: REGISTRATION_FEE });

      expect(await eventRegistration.getParticipantCount()).to.equal(2);
      expect(await eventRegistration.isRegistered(attendee1.address)).to.be.true;
      expect(await eventRegistration.isRegistered(attendee2.address)).to.be.true;
    });
  });

  describe("View Functions", function () {
    beforeEach(async function () {
      await eventRegistration.connect(attendee1).register({ value: REGISTRATION_FEE });
      await eventRegistration.connect(attendee2).register({ value: REGISTRATION_FEE });
    });

    it("Should return correct participant count", async function () {
      expect(await eventRegistration.getParticipantCount()).to.equal(2);
    });

    it("Should return all participants", async function () {
      const participants = await eventRegistration.getAllParticipants();
      expect(participants).to.have.lengthOf(2);
      expect(participants[0]).to.equal(attendee1.address);
      expect(participants[1]).to.equal(attendee2.address);
    });

    it("Should check registration status correctly", async function () {
      expect(await eventRegistration.checkRegistration(attendee1.address)).to.be.true;
      expect(await eventRegistration.checkRegistration(owner.address)).to.be.false;
    });

    it("Should return correct contract balance", async function () {
      const balance = await eventRegistration.getContractBalance();
      expect(balance).to.equal(REGISTRATION_FEE.mul(2));
    });
  });

  describe("Withdrawal", function () {
    beforeEach(async function () {
      await eventRegistration.connect(attendee1).register({ value: REGISTRATION_FEE });
    });

    it("Should allow owner to withdraw funds", async function () {
      const contractBalance = await eventRegistration.getContractBalance();
      
      await expect(eventRegistration.connect(owner).withdrawFunds())
        .to.emit(eventRegistration, "FundsWithdrawn")
        .withArgs(owner.address, contractBalance);

      expect(await eventRegistration.getContractBalance()).to.equal(0);
    });

    it("Should prevent non-owner from withdrawing", async function () {
      await expect(
        eventRegistration.connect(attendee1).withdrawFunds()
      ).to.be.revertedWith("EventRegistration: Only owner can withdraw funds");
    });
  });
});
