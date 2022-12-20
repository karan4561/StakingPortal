// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/interface/IToken.sol";
import "hardhat/console.sol";

contract Staking {
    IToken RewardToken;
    IERC721 nft;
    address owner;

    uint256 totalStaked;
    bool public initialized;
    bool claimable;
    uint256 stakingTime = 50 seconds;
    uint256 startingTime;
    uint256 token = 10e18;

    struct staker{
        uint256[] ListOfToken;
        mapping(uint256=>uint256) TimeInitiate;
        uint256 balance;
        uint256 rewardCollected;
    }

    mapping(address=>staker) Stakers;
    mapping(uint256=>address) TokenOwner;

    modifier OnlyOwner(){
        require(msg.sender==owner,"You are not the owner of the Contract");
        _;
    }
    constructor(IToken _RewardToken, IERC721 _nft){
        _RewardToken = RewardToken;
        _nft = nft;
        owner = msg.sender;
    }

    event Staked(address _user, uint256 amount);

    event UnStaked(address owner, uint256 amount);

    event RewardPaid(address indexed user, uint256 reward);

    function initialize() public OnlyOwner(){
        require(initialized==false,"Contract already initialized");
        initialized = true;
        startingTime = block.timestamp;
    }

    function setTokenClaimable(bool _enabled) public OnlyOwner(){
        claimable = _enabled;
    }

    function viewTokensListed(address _user) public view returns(uint256[] memory tokenIDs){
        return Stakers[_user].ListOfToken;
    }

    function stake(uint256 tokenId) public{
        _stake(msg.sender,tokenId);
    }

    function stakeBatch(uint256[] memory tokenId) public{
        for(uint256 i=0;i<tokenId.length;i++){
            _stake(msg.sender,tokenId[i]);
        }
    }

    function unstake(uint256 tokenId) public{
        claimReward(msg.sender);
        _unstake(msg.sender,tokenId);
    }

    function _stake(address user, uint256 tokenId) internal {
        require(nft.ownerOf(tokenId)==user,"User is not the owner of the tokenId");
        require(initialized,"Contract is not initialized");
        
        staker storage s1 = Stakers[user];
        s1.ListOfToken.push(tokenId);
        s1.TimeInitiate[tokenId]=block.timestamp;
        
        TokenOwner[tokenId]=user;

        nft.approve(address(this), tokenId);
        nft.safeTransferFrom(user, address(this), tokenId);

        totalStaked++;
        emit Staked(user, tokenId);

    }

    function _unstake(address user, uint256 tokenId) internal {
        require(user==nft.ownerOf(tokenId),"User is not the owner of the tokenId");
        
        staker storage s1 = Stakers[user];
        s1.TimeInitiate[tokenId]=0;
        delete TokenOwner[tokenId];

        nft.safeTransferFrom(user, address(this), tokenId);
        totalStaked--;

        s1.ListOfToken.pop();

        emit UnStaked(user, tokenId);
    }

    function updateReward(address _user) public{
        staker storage s1 = Stakers[_user];
        uint256[] memory list = s1.ListOfToken;

        for(uint i=0;i<list.length;i++){
            if(s1.TimeInitiate[list[i]]>0){
                uint256 stakedDays = ((block.timestamp - uint(s1.TimeInitiate[list[i]])))/stakingTime;
                uint256 leftTime = (block.timestamp - uint(s1.TimeInitiate[list[i]]))%stakingTime;

                s1.balance = stakedDays*token;
                s1.TimeInitiate[list[i]]=block.timestamp + leftTime;

            }

            console.log(s1.balance);
        }
    }

    function claimReward(address _user) public{
        staker storage s1 = Stakers[_user];
        
        require(s1.balance>0,"Insufficient Balance");

        RewardToken.mint(_user, s1.balance);

        emit RewardPaid(_user, s1.balance);

        s1.rewardCollected+=s1.balance;
        s1.balance=0;
    }
    


}