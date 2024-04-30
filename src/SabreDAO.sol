// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract SabreDAO is ERC20, ERC20Burnable, Ownable, ERC20Permit, ERC20Votes {
    constructor(address initialOwner) ERC20("SabreDAO", "SBR") Ownable(initialOwner) ERC20Permit("SabreDAO") {
        // mint 50 tokens to msg.sender = deployer
        _mint(msg.sender, 50 * 10 ** decimals());
        // mint uint256 keepTeamAmount = (keepPeercentage * currentTotalSupply) / 100;
        // keepPeercentage = 20
        // Mint 10 tokens to this contract`
        _mint(address(this), 10 * 10 ** decimals());
        // Now token.totalSupply() = 60 tokens
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Votes) {
        super._update(from, to, value);
    }

    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}
