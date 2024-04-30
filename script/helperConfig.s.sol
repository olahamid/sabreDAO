//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";

contract helperConfig is Script {
    networkConfig public activeNetworkConfig;

    struct networkConfig {
        uint256 _proposalFee;
        uint256 _votingFee;
        uint256 _timePoint;
        uint256 _proposalID;
        // address sabreDAOAddress;
        uint256 deployer_Key;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSapoliaETH();
        } else if (block.chainid == 31337) {
            activeNetworkConfig = getAnvilETH();
        } else {
            activeNetworkConfig = getArbitrumETH();
        }
    }

    function getSapoliaETH() public view returns (networkConfig memory) {
        return networkConfig({
            _proposalFee: 1000 wei,
            _votingFee: 100 wei,
            _timePoint: block.timestamp,
            _proposalID: 0,
            deployer_Key: 0xba34606fbc483cf683622e2c8ae6aebd2de06c5eb66c5b2d516cf8fcb8021d2a
        });
    }

    function getAnvilETH() public view returns (networkConfig memory) {
        return networkConfig({
            _proposalFee: 1000 wei,
            _votingFee: 100 wei,
            _timePoint: block.timestamp,
            _proposalID: 0,
            deployer_Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
        });
    }

    function getArbitrumETH() public view returns (networkConfig memory) {
        return networkConfig({
            _proposalFee: 1000 wei,
            _votingFee: 100 wei,
            _timePoint: block.timestamp,
            _proposalID: 0,
            deployer_Key: 0xb3ee64f345101a8cedc4eef61af5ad651495fa8ada4f62e456ad721009417955
        });
    }
}
