// SPDX-License-Identifier: MIT

// ISabreDAOEngine.sol
pragma solidity ^0.8.20;

interface ISabreDAOEngine {
    function _getBalanceAtTime(address account, uint256 timepoint) external view returns (uint256);
}
