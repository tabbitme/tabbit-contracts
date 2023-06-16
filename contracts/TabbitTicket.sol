// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/ITabbitCard.sol";
import "./interfaces/IERC6551Registry.sol";

contract TabbitTicket is ERC1155, Ownable, ReentrancyGuard {
    uint256 public totalSupply;

    address public tabbitCardAddress;
    address public registryAddress;
    address public implementationAddress;

    struct TicketConfig {
        address admin;
        uint256 maxSupply;
        uint256 currentSupply;
        string imageUri;
    }

    mapping(uint256 => TicketConfig) private ticketConfigs;

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
        string memory _imageUri
    ) external {
        ticketConfigs[totalSupply] = TicketConfig({
            admin: msg.sender,
            maxSupply: _maxSupply,
            currentSupply: 0,
            imageUri: _imageUri
        });

        totalSupply++;
    }

    /// @param _to via email address
    function issueTickets(
        uint256 tokenId,
        address _to,
        uint256 _quantity
    ) external nonReentrant onlyTicketAdmin(tokenId) {
        require(
            ticketConfigs[tokenId].currentSupply + _quantity <=
                ticketConfigs[tokenId].maxSupply,
            "Exceeds max supply."
        );

        if (!hasTBA(tokenId)) {
            _createTBA(tokenId);
            _mintCard(_to);
        }


        address smartWalletAddress = getTBAAddress(tokenId);
        _mint(smartWalletAddress, tokenId, _quantity, "");

        ticketConfigs[tokenId].currentSupply += _quantity;
    }

    function _createTBA(uint256 tokenId) internal {
        IERC6551Registry(registryAddress).createAccount(
            implementationAddress,
            80001,
            tabbitCardAddress,
            tokenId,
            0,
            ""
        );
    }

    function _mintCard(address _to) internal {
        ITabbitCard(tabbitCardAddress).mintCard(_to, "");
    }

    modifier onlyTicketAdmin(uint256 tokenId) {
        require(
            msg.sender == ticketConfigs[tokenId].admin,
            "Only Ticket Admin can call this function."
        );
        _;
    }

    function uri(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        string memory tokenURI = ticketConfigs[tokenId].imageUri;
        // If token URI is set, concatenate base URI and tokenURI (via abi.encodePacked).
        return bytes(tokenURI).length > 0 ? tokenURI : super.uri(tokenId);
    }

    function setTokenURI(
        uint256 tokenId,
        string memory _tokenURI
    ) external onlyTicketAdmin(tokenId) {
        require(bytes(_tokenURI).length > 0, "TabbitTicket: Invalid URI.");
        ticketConfigs[tokenId].imageUri = _tokenURI;
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        _setURI(_baseURI);
    }

    function getTBAAddress(uint256 tokenId) public view returns (address) {
        return
            IERC6551Registry(registryAddress).account(
                implementationAddress,
                80001,
                tabbitCardAddress,
                tokenId,
                0
            );
        //  == _to;
    }

    function hasTBA(uint256 tokenId) public view returns (bool) {
        return _isCA(getTBAAddress(tokenId));
    }

    /// @dev internal
    function _isCA(address addr) public view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    // modifier onlyTBAOwner() {
    //     require(msg.sender == TBAOwner, "Only TBA Owner can call this function.");
    //     _;
    // }
}
