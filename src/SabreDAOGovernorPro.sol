// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

/*
* @title SABRE DAO ENGINE
* @author Ola Hamid
* @Aboout this is a engine contract to a dao token, it is used to take in fund from other based projects to generate income, and main focus is to allow usser stay early and secure to all investment. 
 * This is an ERC20coin with the properties:
 * - erc20 bought and sell 
 * - sVault
 * - Algorithmically take in funds, store projects info and pay out funds to the project once target is being met
 *
 * 
 *
 * @notice
*/

import {Governor, IGovernor} from "../lib/openzeppelin-contracts/contracts/governance/Governor.sol";
import {GovernorSettings} from "../lib/openzeppelin-contracts/contracts/governance/extensions/GovernorSettings.sol";
import {GovernorCountingSimple} from
    "../lib/openzeppelin-contracts/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorVotes, IVotes} from "../lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from
    "../lib/openzeppelin-contracts/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {
    GovernorTimelockControl,
    TimelockController
} from "../lib/openzeppelin-contracts/contracts/governance/extensions/GovernorTimelockControl.sol";
import {SabreDAO} from "../src/SabreDAO.sol";
// import {SabreDAOEngine} from "../src/SabreDAOEngine.sol";
import {ISabreDAOEngine} from "./ISabreDAOEngine.sol";

contract SabreDAOGovernorPro is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    // function totalVoting_power(address contractAddress) onlyOwner internal view returns(uint ) {
    //     uint timepoint = block.timestamp;
    //     _getVotes(contractAddress, timepoint, "");
    // }
    ISabreDAOEngine public sabreDAOEngine;

    //  mapping(uint256 proposalID => bool sucess) public m_execute;

    constructor(ISabreDAOEngine _sabreDAOEngineAddress, IVotes _token, TimelockController _timelock)
        Governor("SABREDAO TOKEN")
        GovernorSettings(1, /* 1 day */ 50400, /* 1 week */ 0)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
        GovernorTimelockControl(_timelock)
    {
        sabreDAOEngine = ISabreDAOEngine(_sabreDAOEngineAddress);
    }

    ///////////////////////////////////////////////////
    //////////////PUBLIC AND EXTERNAL FUNCTION/////////
    ///////////////////////////////////////////////////
    //the following code are decleared as virtual and they must be immplemented in our engine code

    function votingDelay() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingDelay();
    }

    function votingPeriod() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(Governor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function proposalNeedsQueuing(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.proposalNeedsQueuing(proposalId);
    }

    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.proposalThreshold();
    }

    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint48) {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        Governor._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public payable override returns (uint256) {
        return super.execute(targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public override returns (uint256) {
        return super.cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) {
        return super._executor();
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public override returns (uint256) {
        return super.propose(targets, values, calldatas, description);
    }

    function castVoteWithReason(
        uint256 proposalId, //FOR THE VIRTUal function....note with the small id
        uint8 support,
        string calldata reason
    ) public override returns (uint256) {
        return super.castVoteWithReason(proposalId, support, reason);
    }
    // return proposalId;

    // function _executeOperations(
    //     uint256 /* proposalId */,
    //     address[] memory targets,
    //     uint256[] memory values,
    //     bytes[] memory calldatas,
    //     bytes32 /*descriptionHash*/
    // ) external override {
    //     // m_execute[proposalID] = true;
    //     proposalID--;
    // }
    // //     for (uint256 i = 0; i < targets.length; ++i) {
    // //         (bool success, bytes memory returndata) = targets[i].call{value: values[i]}(calldatas[i]);
    // //     }
    // // }
    // function _cancel(
    //     address[] memory targets,
    //     uint256[] memory values,
    //     bytes[] memory calldatas,
    //     bytes32 descriptionHash
    // ) internal override returns (uint256) {

    // }

    ///////////////////////////////////////////////////
    ///////////////INTERNAL AND PRIVATE FUNCTION///////
    ///////////////////////////////////////////////////
    //QV voting methodology implemented.
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function _getVotes(address account, uint256 timepoint, bytes memory params)
        internal
        view
        virtual
        override(Governor, GovernorVotes)
        returns (uint256)
    {
        uint256 balance = getBalanceAtTime(account, block.timestamp);
        uint256 QVWeight = sqrt(balance);
        super._getVotes(account, timepoint, params);
        return QVWeight;
    }

    function getBalanceAtTime(address account, uint256 timepoint) internal view virtual returns (uint256) {
        return sabreDAOEngine._getBalanceAtTime(account, timepoint);
    }

    function getvote() external view returns (uint256) {
        // string memory message = "this is your current vote";
        // bytes memory params = abi.encodePacked(message);
        uint256 timepoint = block.timestamp;
        uint256 QVWeight = _getVotes(msg.sender, timepoint, "");
        return QVWeight;
    }
}
