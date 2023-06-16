// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract TabbitCard is ERC721URIStorage, Ownable, ReentrancyGuard {

    address public allowedContract;

    uint256 public totalSupply;

    event minted(uint256);

    constructor() ERC721("TabbitCard", "TBCARD") {}

    function mintCard(address to, string memory tokenURI) external nonReentrant onlyAllowedContract {
        _safeMint(to, totalSupply);
        _setTokenURI(totalSupply++, tokenURI);
        emit minted(totalSupply);
    }

    function gift(address to) external {
        this.safeTransferFrom(msg.sender, to, totalSupply);
    }

    function setAllowedContract(address _contractAddress) external onlyOwner {
        allowedContract = _contractAddress;
    }

    modifier onlyAllowedContract() {
        require(msg.sender == allowedContract, "Only allowed contract can call this function.");
        _;
    }
    
}
