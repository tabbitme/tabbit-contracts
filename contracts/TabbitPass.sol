// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./TabbitTicket.sol";
import "./interfaces/ITabbitPass.sol";

contract TabbitPass is ITabbitPass, ERC721, Ownable, ReentrancyGuard {

    address public allowedContract;
    address public tabbitTicketAddress;

    uint256 public totalSupply;

    string public baseImageURI = "https://tabbit.me/metadata/";

    /// @dev Ticket ID to Card ID
    mapping (uint256 => uint256) public ticketIds;

    /// @dev Ticket Owner Address to Card Image URI
    mapping (address => string) public tokenURIs;

    event minted(uint256);

    constructor() ERC721("TabbitCard", "TBCARD") {}

    function mintCard(address _to, uint256 _ticketId) external nonReentrant onlyAllowedContract {
        _safeMint(_to, totalSupply);
        ticketIds[totalSupply] = _ticketId;
        totalSupply++;
    }

    function setAllowedContract(address _contractAddress) external onlyOwner {
        allowedContract = _contractAddress;
    }

    modifier onlyAllowedContract() {
        require(msg.sender == allowedContract, "Only allowed contract can call this function.");
        _;
    }

    modifier onlyCardAdmin(uint256 tokenId) {
        require(getCardAdmin(tokenId) == tx.origin, "Only card admin can call this function.");
        _;
    }

    function getCardAdmin(uint256 tokenId) public view returns (address) {
        return TabbitTicket(tabbitTicketAddress).getTicketAdmin(ticketIds[tokenId]);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return tokenURIs[getCardAdmin(tokenId)];
    }

    function setBaseURI(string memory _baseURI) external {
        tokenURIs[msg.sender] = _baseURI;
    }

    function getTotalSupply() external view returns (uint256) {
        return totalSupply;
    }

    

}
