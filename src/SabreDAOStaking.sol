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

*/

import {SabreDAO} from "../src/SabreDAO.sol";
import {console} from "../lib/forge-std/src/console.sol";

contract SabreDAOStaking {
    /////////////////
    //STATE VARIBLE///
    /////////////////
    SabreDAO public sabreDAO;
    uint256 public s_totalStakingSupply;
    uint256 public s_totalStakeableSupply;
    uint256 public s_rewardPerTokenStored;
    uint256 public N_compoundIntrest = 12;
    // uint public R_annualRate ;
    // uint public r_rate = 10;
    uint256 public APY_Percentage; //APY 10% rate
    uint256 public t_investedTime = block.timestamp - s_lastUpdate;
    //  uint public t_investedTime =

    // uint256 public reward_Rate = 100;
    uint256 public s_lastUpdate;

    //mappings
    mapping(address user => uint256 amount) public sm_balance;

    mapping(address user => uint256 amount) public s_UserRewardPerTokenPaid;

    mapping(address user => uint256 amount) public sm_reward;
    ////////////

    //error///
    /////////

    error e_NeedMoreZero();
    error e_StakingError();
    error e_unStakingError();
    error e_rewardClaimError();
    error e_rewardError();
    ///////////
    //modifier//
    ///////////

    modifier moreThanZero(uint256 amount) {
        if (amount <= 0) {
            revert e_NeedMoreZero();
        }
        _;
    }

    //update reward
    //so the update reward, the way it works is that every time the modifier is called this set the current time to s_lastUpdate(s.v)
    modifier updateReward(address account) {
        // s_rewardPerTokenStored = rewardPerToken(account);
        s_lastUpdate = block.timestamp;
        // sm_reward[msg.sender] = rewardPerToken(account);
        s_UserRewardPerTokenPaid[account] += s_rewardPerTokenStored;
        _;
    }

    constructor(address _SabreDAOAddress, uint256 apy) {
        sabreDAO = SabreDAO(_SabreDAOAddress);
        APY_Percentage = apy;
        // R_annualRate = r;
        // N_compoundIntrest = n;
        // t_investedTime = t;
    }

    ////////////
    //function//
    ////////////
    //f-stake
    function _stake(uint256 amountToStake) public updateReward(msg.sender) moreThanZero(amountToStake) {
        sm_balance[msg.sender] += amountToStake;
        s_totalStakeableSupply += amountToStake;
        bool sucess = sabreDAO.transferFrom((msg.sender), address(this), amountToStake);
        if (!sucess) {
            revert e_StakingError();
        }
    }
    //f-earned

    //f-unstake
    function _unStake(uint256 amountToUnstake) public updateReward(msg.sender) {
        sm_balance[msg.sender] -= amountToUnstake;
        s_totalStakeableSupply -= amountToUnstake;
        bool sucess = sabreDAO.transfer(msg.sender, amountToUnstake);
        if (!sucess) {
            revert e_unStakingError();
        }
    }

    //f claimReward
    function _claimReward() public virtual updateReward(msg.sender) {
        uint256 Reward = sm_reward[msg.sender];
        bool success = sabreDAO.transferFrom(address(sabreDAO), msg.sender, Reward);
        if (!success) {
            revert e_rewardClaimError();
        }
    }

    function _claimAndUnstake(uint256 amountToUnstake) public {
        /**
         * @audit-qa Reentrancy, just change the order of the instructions to:
         *           _unStake(amountToUnstake);
         *           _claimReward();
         *           and add the OZ ReentrancyGuard
         */
        _claimReward();
        _unStake(amountToUnstake);
    }

    // rewardPerToken
    // function rewardPerToken() public view returns (uint256) {
    //     if (s_totalStakingSupply == 0) {
    //         return s_rewardPerTokenStored;
    //     } else {
    //         return (
    //             s_rewardPerTokenStored
    //                 + (((block.timestamp /*+*/ - s_lastUpdate) / (reward_Rate / 1 * 18))) / s_totalStakingSupply
    //         );
    //     }
    // }

    function rewardAndAPY(address user, uint256 _investedTime) public returns (uint256) {
        // APY
        // uint256 year = _investedTime / 31536000; //31, 536, 000 seconds
        /* uint month = _investedTime / 2629746 ;
        uint week = _investedTime / 604800;*/
        // _investedTime = t_investedTime;
        // NOTE that if you are using t_investedTime you will have to comment out the param _investedTime
        uint256 day = _investedTime / 86400;

        console.log(day, "year/day is ");
        console.log((APY_Percentage * day), "total ");
        uint256 APYInValue = (APY_Percentage * day);

        //rewrd
        uint256 userAmount = sm_balance[user];
        // uint APYvalue = APY(t_investedTime);
        // uint totalAmountCurrentBeingStacked = s_totalStakeableSupply;

        uint256 totalReward = s_totalStakeableSupply * APYInValue;
        uint256 userReward = (userAmount * totalReward) / (s_totalStakeableSupply * 100000);
        sm_reward[user] += userReward;
        return userReward;
    }

    function APY(uint256 _investedTime) public view returns (uint256) {
        uint256 year = _investedTime / 31536000; //31, 536, 000 seconds
        /* uint month = _investedTime / 2629746 ;
        uint week = _investedTime / 604800;
        uint day =  _investedTime /  86400 ; */
        console.log(year, "year is ");
        console.log((APY_Percentage * year), "total ");
        uint256 APYInValue = (APY_Percentage * year);

        // console.log(year, "this is the current year");
        // console.log(r_rate, "this is the st APY CALC");
        // uint APYinvalue1 = 100 + (r_rate);
        // console.log(APYinvalue1, "this is the 1st APY CALC");
        // uint APYinvalue2 = APYinvalue1 ** (N_compoundIntrest * year);
        // console.log(APYinvalue2, "this is the 2st APY CALC");
        // uint APYInValue = (APYinvalue2 - 1 );
        console.log(APYInValue, "ahhhhhh APYINVALUE");
        return APYInValue;
    }

    function _getStake(address staker) external view returns (uint256) {
        return sm_balance[staker];
    }

    function _getTotalStakedAmount() external view returns (uint256) {
        return s_totalStakeableSupply;
    }

    function getClaimReward(address claimer) external view returns (uint256) {
        return sm_reward[claimer];
    }
}
