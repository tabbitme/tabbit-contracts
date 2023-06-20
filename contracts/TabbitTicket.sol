// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./interfaces/ITabbitPass.sol";
import "./interfaces/IERC6551Registry.sol";

contract TabbitTicket is ERC1155, Ownable, ReentrancyGuard {

    string public name = "TabbitTicket";
    string public symbol = "TTicket";

    uint256 public totalSupply;

    address public tabbitCardAddress;
    address public registryAddress;
    address public implementationAddress;

    event TBACreated(address indexed account);

    struct TicketConfig {
        address admin;
        uint256 maxSupply;
        uint256 currentSupply;
        string imageUri;
        string description;
        string name;
    }

    mapping(uint256 => TicketConfig) public ticketConfigs;

    mapping(address => mapping(address => address)) public TBAAddresses;

    mapping(address => uint256[]) public ticketIds;

    constructor() ERC1155("") {}

    function init(
        address _registryAddress,
        address _tabbitCardAddress,
        address _implementationAddress
    ) external onlyOwner {
        registryAddress = _registryAddress;
        tabbitCardAddress = _tabbitCardAddress;
        implementationAddress = _implementationAddress;
    }

    function createTicket(
        uint256 _maxSupply,
        string memory _name,
        string memory _description,
        string memory _imageUri
    ) external {
        ticketConfigs[totalSupply] = TicketConfig({
            admin: msg.sender,
            maxSupply: _maxSupply,
            currentSupply: 0,
            imageUri: _imageUri,
            description: _description,
            name: _name
        });

        ticketIds[msg.sender].push(totalSupply);

        totalSupply++;
    }

    /// @param _to email address
    function issueTickets(
        uint256 ticketId,
        address _to,
        uint256 _quantity
    ) external nonReentrant onlyTicketAdmin(ticketId) {
        require(
            ticketConfigs[ticketId].currentSupply + _quantity <=
                ticketConfigs[ticketId].maxSupply,
            "Exceeds max supply."
        );

        address smartWalletAddress = TBAAddresses[_to][msg.sender];

        if (smartWalletAddress == address(0)) {
            uint256 cardId = ITabbitPass(tabbitCardAddress).getTotalSupply();

            _createTBA(cardId);
            _mintCard(_to, ticketId);

            smartWalletAddress = getTBAAddress(cardId);
            emit TBACreated(smartWalletAddress);
            TBAAddresses[_to][msg.sender] = smartWalletAddress;
        }

        _mint(smartWalletAddress, ticketId, _quantity, "");

        ticketConfigs[ticketId].currentSupply += _quantity;
    }

    function _createTBA(uint256 cardId) internal {
        IERC6551Registry(registryAddress).createAccount(
            implementationAddress,
            80001,
            tabbitCardAddress,
            cardId,
            0,
            bytes("")
        );
    }

    function _mintCard(address _to, uint256 ticketId) internal {
        ITabbitPass(tabbitCardAddress).mintCard(_to, ticketId);
    }

    modifier onlyTicketAdmin(uint256 ticketId) {
        require(
            msg.sender == ticketConfigs[ticketId].admin,
            "Only Ticket Admin can call this function."
        );
        _;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                ticketConfigs[tokenId].name,
                                '", "description": "',
                                ticketConfigs[tokenId].description,
                                '", "image" : "',
                                ticketConfigs[tokenId].imageUri,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function setTokenURI(
        uint256 ticketId,
        string memory _tokenURI
    ) external onlyTicketAdmin(ticketId) {
        require(bytes(_tokenURI).length > 0, "TabbitTicket: Invalid URI.");
        ticketConfigs[ticketId].imageUri = _tokenURI;
    }

    function getTicketAdmin(uint256 ticketId) external view returns (address) {
        return ticketConfigs[ticketId].admin;
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        _setURI(_baseURI);
    }

    function getTBAAddress(uint256 cardId) public view returns (address) {
        return
            IERC6551Registry(registryAddress).account(
                implementationAddress,
                80001,
                tabbitCardAddress,
                cardId,
                0
            );
    }

    function isContractAddress(address addr) public view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function getTicketIdsForAdmin(
        address _adminAddress
    ) external view returns (uint256[] memory) {
        return ticketIds[_adminAddress];
    }
}
