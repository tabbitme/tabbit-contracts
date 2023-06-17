// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.19;

interface ITabbitCard {
    function mintCard(address to) external;

    function getTotalSupply() external view returns (uint256);
}