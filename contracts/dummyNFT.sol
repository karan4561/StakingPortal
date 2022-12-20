// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "contracts/interface/IDummyNFT.sol";
import "hardhat/console.sol";


contract dummyNFT is ERC721, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("DummyNFT", "DA"){
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function safeMint(address to) public onlyRole(MINTER_ROLE){
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        console.log(tokenId);
        _safeMint(to, tokenId);

    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns(bool){
        return super.supportsInterface(interfaceId);
    }
}