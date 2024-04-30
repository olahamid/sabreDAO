// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {helperConfig} from "../script/helperConfig.s.sol";
import {SabreDAOEngine} from "../src/SabreDAOEngine.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {SabreDAO} from "../src/SabreDAO.sol";
import {S_vault} from "../src/S_vault.sol";
import {SabreDAOStaking} from "../src/SabreDAOStaking.sol";

contract deploySabreDAOEngine is Script {
    struct DeploymentResult {
        SabreDAO sabreDAO;
        helperConfig helperConfig;
        SabreDAOEngine sabreDAOEngine;
        S_vault sVault;
        TimeLock timeLock;
        SabreDAOStaking sabreDAOStaking;
    }

    address[] public proposer;
    // uint public N_compoundIntrest = 12;
    // uint public R_annualRate = 20;
    uint256 public _apy = 10;

    function run() external returns (DeploymentResult memory) {
        helperConfig HelperConfig = new helperConfig();
        (
            uint256 _proposalFee,
            uint256 _votingFee,
            uint256 _timePoint,
            uint256 _proposalID,
            // address sabreDAOAddress;
            uint256 deployer_Key
        ) = HelperConfig.activeNetworkConfig();
        vm.startBroadcast(deployer_Key);

        SabreDAO SBRToken = new SabreDAO(msg.sender);
        S_vault SBRVault = new S_vault(address(SBRToken));

        SabreDAOStaking SBRStaking = new SabreDAOStaking(address(SBRToken), _apy);
        SabreDAOEngine SBREngine =
            new SabreDAOEngine(_proposalFee, _votingFee, _timePoint, _proposalID, address(SBRToken));
        TimeLock timelock = new TimeLock(30, proposer, proposer);

        // SBRToken.mintToken();
        SBRToken.transferOwnership(address(SBREngine));
        vm.stopBroadcast();
        // return (SBRToken, HelperConfig, SBREngine, SBRVault, timeLock);
        return DeploymentResult({
            sabreDAO: SBRToken,
            helperConfig: HelperConfig,
            sabreDAOEngine: SBREngine,
            sVault: SBRVault,
            timeLock: timelock,
            sabreDAOStaking: SBRStaking
        });
    }
}
