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
//propose : the is the Aspect where the project drops a proposal
//vote
//execute
//cancel
//stake
//snapshot
// invest  == permit users to invest on the Svault basically transferring a x amount to the vault
// transferFunds == function can be called only by the deployer it permit to witdraw all founds from the Svault and transfer it to a new address ( this function use multisig signatures) so before being able witdhraw 3-4 signatures are required to emit the withdraw
// refound == only callable by the owner used in case of the cap is no reached or there are a  unexpected problem with the project it permit a refounds for all the address who have invested
import {Governor, IGovernor} from "../lib/openzeppelin-contracts/contracts/governance/Governor.sol";
import {SabreDAO} from "../src/SabreDAO.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SabreDAOStaking} from "../src/SabreDAOStaking.sol";
import {SabreDAOGovernorPro} from "../src/SabreDAOGovernorPro.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {S_vault} from "../src/S_vault.sol";
import {ISabreDAOEngine} from "../src/ISabreDAOEngine.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract SabreDAOEngine is Ownable, ISabreDAOEngine, ReentrancyGuard {
    ///////////////////////////////////////////////////
    ////////////////ERROR//////////////
    ///////////////////////////////////////////////////
    error SabreDAO_noEnoughToken();
    error SabreDAO_notAnHolder();
    error ProposalFee_notCorrect();
    error voteFee_notCorrect();
    error SBRState_notCorrect();
    error SBRinvalidSupportError();
    error invalidProposalIDError();
    error proposalExecuteError();
    error currentVaultStatusError();
    error s_vaultTimePostError();

    //////////////////////////////////////
    /////////ENUM///////////////////////
    ////////////////////////////////////
    enum SabreDAO_State {
        open,
        close,
        ongoing
    }
    enum vote_State {
        _abstain, //super never vote toward the project mainly for scam prject
        _for, //in support of the project
        _against //agaist support

    }
    enum vault_State {
        vault_open,
        vault_close
    }

    ////////////////////////////////////
    ////////EVENT//////////////////////
    ///////////////////////////////////
    event Investment(address indexed investor, uint256 proposalID, uint256 amount);
    event refund(address indexed refunder, uint256 proposalID, uint256 amount);
    event buyer(address indexed buyer, uint256 amount);
    event en_Proposer(address targets, uint256 values, bytes calldatas, string description);
    event ev_Voter( //FOR THE VIRTUal function....note with the small id
    uint256 proposalId, uint8 support, string reason);
    event ev_stake(address staker, uint256 amount);
    event ev_claimAndUnstaker(address unstaker, uint256 amount);
    event ev_getStakeAmount(address getStakerAmount);
    event vaultStatusChanged(vault_State newState);
    event vaultduration(uint256 proposalId, uint256 _duration, uint256 amountToRefund);

    ///////////////////////////////////////////////////
    ////////////////STATEVARIABLE&MAPPING//////////////
    ///////////////////////////////////////////////////
    SabreDAO public sabreDAO;
    SabreDAOStaking public SBRSStaking;
    SabreDAOGovernorPro public SBRDAOGovernorPro;
    SabreDAO_State public SBRDAO_State;
    vote_State public Vote_State;
    vault_State public Vault_State;
    uint256 public last_TimePoint;
    S_vault public s_vault;
    /////////////////////////
    //gov state variables////
    /////////////////////////

    uint256 public proposeFee;
    uint256 public votingFee;
    //    uint public proposald = 0;

    // Proposal public proposal;

    mapping(address user => uint256 amount) public m_SabreDAOBuy;
    mapping(uint256 proposalID => Proposal) public m_Proposals;
    // mapping(uint256 proposalID => mapping(uint[] _value=> address _targets )) private m_Proposals;
    mapping(uint256 proposalID => Votes) public m_votes;
    // mapping (uint256 proposalID => uint8 _support) m_votes;
    mapping(uint256 proposalID => Proposal) public m_executions;
    mapping(uint256 => bool) public proposalExecuted;
    mapping(uint256 proposalID => mapping(address investor => uint256 investAmount)) public m_vaultsInvest;
    mapping(uint256 => uint256) public totalInvestmentAmounts;
    mapping(uint256 => uint256) public vaultDurations;

    //  mapping(uint256 proposalID => bool sucess) public m_execute;

    // address[] public s_target;
    // address[] public s_value;
    struct Proposal {
        address[] _targets; // Array of project contract addresses
        uint256[] _values; // Amount of investment for each project
        bytes[] _calldatas; // Function signatures and encoded arguments for each project
        string _description; // Human-readable description of the proposal
    }
    // address[] _targets; // Array of project contract addresses
    // uint256[] _values; // Amount of investment for each project
    //     bytes[] _calldatas; // Function signatures and encoded arguments for each project
    //     string _description; // Human-readable description of the proposal

    struct Votes {
        uint256 _proposalId;
        uint8 _support;
        string _reason;
    }
    //         uint _proposalId;
    // uint8 _support;
    // string _reason;
    // uint projectId;
    // uint sv_targets;
    // uint sv_values;

    struct proposeAndVoteData {
        uint256 proposalId;
        address[] targets;
        uint256[] values;
        bytes[] calldatas;
        string description;
        uint8 support;
        string reason;
    }

    address[] public a_projectProposer;
    address[] private a_tokenHolders;
    uint256 public proposalID;
    uint256 public TimePoint = TimePoint / 604800; //coversion to a week

    ////////////////////////////////////
    ///////Modifier////////////////////
    //////////////////////////////////
    modifier onlyHolders(address holders) {
        bool isHolder = false;
        for (uint256 i = 0; i < a_tokenHolders.length; ++i) {
            if (a_tokenHolders[i] == holders) {
                isHolder = true;
                break;
            }
        }
        if (!isHolder) {
            revert SabreDAO_notAnHolder();
        }
        _;
    }

    ///////////////////////////////////////////////////
    //////////////////////CONSTRUCTOR///////////////////
    ///////////////////////////////////////////////////
    constructor(
        uint256 _proposalFee,
        uint256 _votingFee,
        uint256 _timePoint,
        uint256 _proposalID,
        address sabreDAOAddress
    ) Ownable(msg.sender) {
        proposalID = _proposalID;
        SBRDAO_State = SabreDAO_State.open;
        proposeFee = _proposalFee;
        votingFee = _votingFee;
        TimePoint = _timePoint;
        sabreDAO = SabreDAO(sabreDAOAddress);
    }

    /////////////
    //modifier//
    ////////////

    //   function getBalanceAtTime(address Users_account, uint timepoint) internal view virtual returns (uint) {

    // }

    function buy(uint256 amountToBuy) public payable {
        m_SabreDAOBuy[msg.sender] += amountToBuy;
        // sabreDAO._mint(msg.sender, amountToBuy);
        sabreDAO.transferFrom(address(this), msg.sender, amountToBuy);
        a_tokenHolders.push(msg.sender);
        emit buyer(msg.sender, amountToBuy);
    }

    //propose : the is the Aspect where the project drops a proposal

    function Propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public payable onlyHolders(msg.sender) {
        // _targets = targets;
        // _values = values;
        // _calldatas = calldatas;
        // _description = description;
        Proposal memory newPropose =
            Proposal({_targets: targets, _values: values, _calldatas: calldatas, _description: description});
        (bool sucess) = sabreDAO.transferFrom(msg.sender, address(this), proposeFee);
        SBRDAOGovernorPro.propose(targets, values, calldatas, description);
        if (!sucess) {
            revert ProposalFee_notCorrect();
        }
        SBRDAO_State = SabreDAO_State.ongoing;
        proposalID++;
        m_Proposals[proposalID] = newPropose;
        emit en_Proposer(targets[proposalID], values[proposalID], " ", description);

        // SBRDAOGovernorPro.propose(targets, values, calldatas, description);
    }
    //vote

    function vote(
        uint256 proposalId, //FOR THE VIRTUal function....note with the small id
        uint8 support,
        string calldata reason
    ) public payable onlyHolders(msg.sender) {
        proposalId = proposalID;
        // _support = support;
        // _reason = reason;
        Votes memory newVotes = Votes({_proposalId: proposalId, _support: support, _reason: reason});

        bool success = sabreDAO.transferFrom(msg.sender, address(this), votingFee);
        if (!success) {
            revert voteFee_notCorrect();
        }
        if (SBRDAO_State != SabreDAO_State.ongoing) {
            revert SBRState_notCorrect();
        }
        SBRDAOGovernorPro.castVoteWithReason(proposalId, support, reason);

        if (Vote_State == vote_State._abstain) {
            support = 0;
        } else if (Vote_State == vote_State._for) {
            support = 1;
        } else if (Vote_State == vote_State._against) {
            support = 2;
        } else {
            revert SBRinvalidSupportError();
        }
        m_votes[proposalID] = newVotes;
        emit ev_Voter(proposalId, support, reason);
    }

    function execute(
        // uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal onlyOwner {
        // targets = _targets;
        // values = _values;
        // calldatas = _calldatas;
        // descriptionHash = keccak256(abi.encodePacked(descriptionHash));
        Proposal memory newExecutor = Proposal({
            _targets: targets,
            _values: values,
            _calldatas: calldatas,
            _description: " " //ASSIGN AN EMPTY STRING
        });

        SBRDAO_State = SabreDAO_State.close;
        SBRDAOGovernorPro.execute(targets, values, calldatas, descriptionHash);
        m_executions[proposalID] = newExecutor;
        proposalExecuted[proposalID] = true;
    }

    //cancel
    function cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal {
        SBRDAOGovernorPro.cancel(targets, values, calldatas, descriptionHash);
    }

    function executeAndCancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal {
        last_TimePoint = TimePoint;
        execute(targets, values, calldatas, descriptionHash);
        cancel(targets, values, calldatas, descriptionHash);
    }

    //////////////////////////////////////
    ////////S_VAULT//////////////////////
    ////////////////////////////////////
    // CreateS_Vault
    function returnS_vaultProposalAndVoteData() public view returns (proposeAndVoteData[] memory) {
        proposeAndVoteData[] memory allData = new proposeAndVoteData[](proposalID);
        for (uint256 i = 1; i <= proposalID; ++i) {
            Proposal memory proposal = m_Proposals[i];
            Votes memory votee = m_votes[i];
            allData[i - 1] = proposeAndVoteData({
                proposalId: i,
                targets: proposal._targets,
                values: proposal._values,
                calldatas: proposal._calldatas,
                description: proposal._description,
                support: votee._support,
                reason: votee._reason
            });
        }
        return allData;
    }

    //s_vaultInvest
    function s_vaultInvest(uint256 _proposalID, uint256 AmountToInvest) public payable {
        if (_proposalID < proposalID) {
            revert invalidProposalIDError();
        }
        if (Vault_State != vault_State.vault_open) {
            revert currentVaultStatusError();
        }

        m_vaultsInvest[proposalID][msg.sender] += AmountToInvest;
        totalInvestmentAmounts[proposalID] += AmountToInvest;

        s_vault.deposit(AmountToInvest);
        // require(success, "Transfer failed");

        emit Investment(msg.sender, proposalID, AmountToInvest);
    }
    //s_vaultTransferFund

    function s_vaultTransferFundToTarget(uint256 _proposalID) public onlyOwner {
        if (m_Proposals[_proposalID]._targets.length == 0) {
            revert invalidProposalIDError();
        }
        if (!proposalExecuted[_proposalID]) {
            revert proposalExecuteError();
        }
        // Check if the fund-raising goal is met
        if (totalInvestmentAmounts[_proposalID] < m_Proposals[_proposalID]._values[0]) {
            revert("Fund-raising goal not met.");
        }
        //transfere funds to the target addresses
        for (uint256 i = 0; i < m_Proposals[_proposalID]._targets.length; ++i) {
            address target = m_Proposals[_proposalID]._targets[i];
            uint256 amount = m_Proposals[_proposalID]._values[i];
            sabreDAO.transferFrom(address(s_vault), target, amount);
        }
    }

    //s_vaultReFund
    function s_vaultRefund(uint256 _proposalID, uint256 _AmountToReFund) public payable {
        if (_proposalID < proposalID) {
            revert invalidProposalIDError();
        }
        m_vaultsInvest[proposalID][msg.sender] -= _AmountToReFund;

        s_vault.withdraw(_AmountToReFund);
        emit refund(msg.sender, proposalID, _AmountToReFund);
    }

    //s_VaultAllUsersInvestment
    function returnUSERPROFILE(uint256 _proposalID, address user) public view returns (uint256) {
        uint256 investedAmount = m_vaultsInvest[_proposalID][user];
        return investedAmount;
    }
    //s_setlive

    function setVaultStatus() public onlyOwner {
        if (Vault_State == vault_State.vault_open) {
            Vault_State == vault_State.vault_close;
        } else if (Vault_State == vault_State.vault_close) {
            Vault_State = vault_State.vault_open;
        }
        emit vaultStatusChanged(Vault_State);
    }
    //s_VaultGetStatus

    function getCurrentVaultStatus() public view returns (vault_State) {
        return Vault_State;
    }

    function getParticipationAmount(address investor) public view returns (uint256) {
        uint256 totalInvested = 0;
        for (uint256 i = 1; i <= proposalID; ++i) {
            totalInvested += m_vaultsInvest[i][investor];
        }
        return totalInvested;
    }

    function setVaultTimePoint_Duration(uint256 _proposalID, uint256 Duration, uint256 _amountToRefund)
        public
        onlyOwner
    {
        if (_proposalID < proposalID) {
            revert invalidProposalIDError();
        }
        if (Vault_State != vault_State.vault_open) {
            revert currentVaultStatusError();
        }
        uint256 projectTimeLimit = TimePoint + (Duration / 604800);

        if (TimePoint >= projectTimeLimit) {
            ends_VaultInvest(_proposalID, _amountToRefund);
        }
        vaultDurations[_proposalID] = Duration;
        emit vaultduration(_proposalID, Duration, _amountToRefund);
    }

    function getVaultDuration(uint256 _propposalID) public view returns (uint256) {
        return vaultDurations[_propposalID];
    }

    function ends_VaultInvest(uint256 _proposalID, uint256 _AmountToReFund) public {
        setVaultStatus();
        s_vaultRefund(_proposalID, _AmountToReFund);
    }

    //     if (Vault_State != vault_State.vault_open) {
    //         revert currentVaultStatusError();
    //     }
    //     CurrentTimepost = TimePoint;
    //     if (Duration == CurrentTimepost) {
    //         revert s_vaultTimePostError();
    //     }

    // }
    //////////////////////////////////////////////
    ///////////STAKING functionalities///////////////////////
    /////////////////////////////////////////////

    //onlyholders modifier should be added
    // then implement the voting power to increase if the claim
    function stake(uint256 amount) public onlyHolders(msg.sender) {
        SBRSStaking._stake(amount);
        emit ev_stake(msg.sender, amount);
    }

    function unStake(uint256 amount) public {
        SBRSStaking._unStake(amount);
    }

    function claimReward() public {
        SBRSStaking._claimReward();
    }

    function claimAndUnstake(uint256 amountToUnstake) public {
        SBRSStaking._claimAndUnstake(amountToUnstake);
        // SBRDAOGovernorPro.getvote();
        uint256 votingPower = SBRDAOGovernorPro.getvote();
        votingPower = votingPower + (votingPower / 4);
        emit ev_claimAndUnstaker(msg.sender, amountToUnstake);
    }

    function getStakeAmount(address staker) public view returns (uint256) {
        return SBRSStaking._getStake(staker);
    }

    function getTotalStakedAmount() public view returns (uint256) {
        return SBRSStaking._getTotalStakedAmount();
    }
    //GVPRO

    function _getBalanceAtTime(address account, uint256 timePoint) external view virtual returns (uint256) {
        timePoint = TimePoint;
        uint256 amountAtTime = m_SabreDAOBuy[account];
        return amountAtTime;
    }
}
