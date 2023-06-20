// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.19;

interface ITabbitPass {
    function mintCard(address _to, uint256 _ticketId) external;

    function getTotalSupply() external view returns (uint256);
}