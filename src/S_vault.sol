// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SabreDAOEngine} from "../src/SabreDAOEngine.sol";
import {SabreDAO} from "../src/SabreDAO.sol";

contract S_vault {
    SabreDAOEngine public SBRDAOEngine;

    // mapping ()
    // CreateS_Vault
    //s_vaultInvest

    //s_vaultTransferFund

    //s_vaultReFund
    //s_VaultAllUsersInvestment
    //s_setlive
    //s_VaultGetStatus
    /////////////////////
    // CreateS_Vault/////
    ////////////////////
    event ev_Depositor(uint256 amount);
    event ev_Withdrawer(uint256 amount);

    // The SabreDAO token contract address
    address public sabreDAOAddress;

    // Instance of the SabreDAO token
    SabreDAO public sabreDAO;

    constructor(address _sabreDAOAddress) {
        sabreDAOAddress = _sabreDAOAddress;
        sabreDAO = SabreDAO(_sabreDAOAddress);
    }

    // Function to deposit SabreDAO tokens into the contract
    function deposit(uint256 amount) public payable {
        // Transfer tokens from the sender to this contract
        require(sabreDAO.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        emit ev_Depositor(amount);
    }

    // Function to withdraw SabreDAO tokens from the contract
    function withdraw(uint256 amount) public {
        // Transfer tokens from this contract to the sender
        require(sabreDAO.transfer(msg.sender, amount), "Transfer failed");
        emit ev_Withdrawer(amount);
    }

    // Function to get the balance of SabreDAO tokens in the contract
    function getVaultBalance() public view returns (uint256) {
        return sabreDAO.balanceOf(address(this));
    }
}
