// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./TabbitCard.sol";
import "./interfaces/IERC6551Registry.sol";

contract TabbitTicket is ERC1155, Ownable, ReentrancyGuard {

    uint256 public totalSupply;

    address public tabbitCardAddress;

    struct TicketConfig {
        address admin;
        uint256 maxSupply;
        uint256 currentSupply;
        string imageUri;
    }

    mapping (uint256 => TicketConfig) private ticketConfigs;

    constructor() ERC1155("") {}

    function createTicket(uint256 _maxSupply, string memory _imageUri) external {
        TicketConfig memory ticketConfig = TicketConfig({
            admin: msg.sender,
            maxSupply: _maxSupply,
            currentSupply: 0,
            imageUri: _imageUri
        });
        totalSupply++;
    }

    function issueTickets(uint256 tokenId, address _to, uint256 _quantity) external nonReentrant onlyTicketAdmin(tokenId) {       
        require(ticketConfigs[tokenId].currentSupply + _quantity <= ticketConfigs[tokenId].maxSupply, "Exceeds max supply.");

        if (exsitTBA()) {
            
        } else {
            ITabbitCard(tabbitCardAddress).mintCard(_to, "");
        }

        /// @dev _toがTBAのウォレットアドレス
        _mint(_to, tokenId, _quantity, ticketConfigs[tokenId].imageUri);
        ticketConfigs[tokenId].currentSupply += _quantity;
    }

    modifier onlyTicketAdmin(uint256 tokenId) {
        require(msg.sender == ticketConfigs[tokenId].admin, "Only Ticket Admin can call this function.");
        _;
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        string memory tokenURI = ticketConfigs[tokenId].imageUri;
        // If token URI is set, concatenate base URI and tokenURI (via abi.encodePacked).
        return bytes(tokenURI).length > 0 ? tokenURI : super.uri(tokenId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyTicketAdmin(tokenId) {
        ticketConfigs[tokenId].imageUri = _tokenURI;
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        _setURI(_baseURI);
    }

    function 

    // modifier onlyTBAOwner() {
    //     require(msg.sender == TBAOwner, "Only TBA Owner can call this function.");
    //     _;
    // }

}
