
const { inputToConfig } = require("@ethereum-waffle/compiler");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace");

describe("Staking of one NFT", function () {
    it("Should stake one nft and console.log the reward of the first cycle", async function() {
        const [owner, addr1] = await ethers.getSigners();

        const DummyNFTFactory = await ethers.getContractFactory("dummyNFT");
        const TokenFactory = await ethers.getContractFactory("RewardToken");
        const StakingFactory = await ethers.getContractFactory("Staking");

        const DummyNFTContract = await DummyNFTFactory.deploy();
        const TokenContract = await TokenFactory.deploy();

        await DummyNFTContract.deployed();
        await TokenContract.deployed();

        const StakingContract = await StakingFactory.deploy(TokenContract.address, DummyNFTContract.address);

        console.log(StakingContract.address,addr1.address,0);

        await expect(DummyNFTContract.setApprovalForAll(StakingContract.address,true)).to.emit(DummyNFTContract,"ApprovalForAll").withArgs(owner.address,StakingContract.address,true);

        console.log("Staking Contract Deployed : ", StakingContract.address);

        await expect(DummyNFTContract.safeMint(addr1.address)).to.emit(DummyNFTContract,"Transfer").withArgs("0x0000000000000000000000000000000000000000",addr1.address,0);
        await expect(DummyNFTContract.safeMint(addr1.address)).to.emit(DummyNFTContract,"Transfer").withArgs("0x0000000000000000000000000000000000000000",addr1.address,1);
        
        await StakingContract.initialize();
        await StakingContract.setTokenClaimable(true);

        await expect(DummyNFTContract.connect(addr1).setApprovalForAll(StakingContract.address,true)).to.emit(DummyNFTContract,"ApprovalForAll").withArgs(addr1.address,StakingContract.address,true);

        await expect(StakingContract.connect(addr1).stake(2)).to.emit(StakingContract,"Staked").withArgs(addr1.address,2);

        await network.provider.send("evm_increaseTime", [200])
        await network.provider.send("evm_mine")
        
        console.log("Updating reward: ");
        await StakingSystemContract.connect(addr1).updateReward(account1);

        await StakingSystemContract.connect(addr1).claimReward(account1);



    })
} )
