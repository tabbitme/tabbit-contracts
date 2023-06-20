// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./interfaces/ITabbitPass.sol";
import "./TabbitTicket.sol";

contract TabbitPass is ITabbitPass, ERC721, Ownable, ReentrancyGuard {
    address public tabbitTicketAddress;

    uint256 public totalSupply;

    struct PassConfig {
        string name;
        string description;
        string imageUri;
        string website;
    }


    /// @dev Ticket ID to Card ID
    mapping(uint256 => uint256) public ticketIds;

    /// @dev Ticket Owner Address to Card Image URI
    mapping(address => PassConfig) public passConfigs;

    constructor() ERC721("TabbitPass", "TPASS") {}

    function createPass(
        string memory _name,
        string memory _description,
        string memory _imageUri,
        string memory _website
    ) external {
        passConfigs[msg.sender] = PassConfig({
            name: _name,
            description: _description,
            imageUri: _imageUri,
            website: _website
        });
    }

    function mintCard(
        address _to,
        uint256 _ticketId
    ) external nonReentrant onlyAllowedContract {
        _safeMint(_to, totalSupply);
        ticketIds[totalSupply] = _ticketId;
        totalSupply++;
    }

    function setAllowedContract(address _contractAddress) external onlyOwner {
        tabbitTicketAddress = _contractAddress;
    }

    modifier onlyAllowedContract() {
        require(
            msg.sender == tabbitTicketAddress,
            "Only allowed contract can call this function."
        );
        _;
    }

    modifier onlyCardAdmin(uint256 tokenId) {
        require(
            getCardAdmin(tokenId) == tx.origin,
            "Only card admin can call this function."
        );
        _;
    }

    function getCardAdmin(uint256 tokenId) public view returns (address) {
        return
            TabbitTicket(tabbitTicketAddress).getTicketAdmin(
                ticketIds[tokenId]
            );
    }

    function getTotalSupply() external view returns (uint256) {
        return totalSupply;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_exists(tokenId), "TabbitPass: Nonexistent token");

        address adminAddress = getCardAdmin(tokenId);
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"', passConfigs[adminAddress].name,
                                '", "description": "', passConfigs[adminAddress].description,
                                '", "external_url": "', passConfigs[adminAddress].website,
                                '", "image" : "', passConfigs[adminAddress].imageUri,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
}
