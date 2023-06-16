// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.19;

interface ITabbitCard {
    function mintCard(address to, string memory tokenURI) external;
}