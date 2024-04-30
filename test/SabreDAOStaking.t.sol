// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {SabreDAO} from "../src/SabreDAO.sol";
// import {SabreDAOStaking} from "../src/SabreDAOStaking.sol";
import {SabreDAOStaking} from "../src/SabreDAOStaking.sol";
import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {SabreDAOEngine} from "../src/SabreDAOEngine.sol";

contract SabreDAOStakingTest is Test {
    ////////////////////
    //    USERS    /////
    ////////////////////

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");

    ////////////////////
    // CONTRACTS   /////
    ////////////////////
    SabreDAO sabreDAO;
    SabreDAOStaking staking;
    SabreDAOEngine engine;
    uint256 public N_compoundIntrest = 12;
    // uint public R_annualRate = 20;
    // uint public T_time = 31536000;
    uint256 public _investedTime = 31536000;
    uint256 public _investedDayTime = 86400;
    uint256 public _apy = 10;
    // uint

    function setUp() public {
        vm.startPrank(deployer);
        sabreDAO = new SabreDAO(deployer);
        // Deploy the SabreDAOStaking contract with the mock SabreDAO as the DAO
        staking = new SabreDAOStaking(address(sabreDAO), _apy);
        // Set the user address for testing
        vm.stopPrank();
    }

    function testStake() public {
        // Mint some tokens to the user's address
        vm.startPrank(deployer);
        sabreDAO.mint(user, 1000 * 1e18);

        vm.stopPrank();
        // Approve the SabreDAOStaking contract to spend tokens on behalf of the user

        console.log(sabreDAO.balanceOf(address(sabreDAO)), "sabreDAO amount");

        // Stake 500 tokens
        vm.startPrank(user);
        sabreDAO.approve(address(staking), 1000 * 1e18);
        staking._stake(500 * 1e18);
        vm.stopPrank();
        console.log(staking.sm_balance(user), "mapping value");
        // Check that the user's staked balance is updated correctly
        assertEq(staking._getStake(user), 500 * 1e18, "User's staked balance should be 500");
        console.log(staking._getStake(user));
        // Check that the total staked supply is updated correctly
        assertEq(staking._getTotalStakedAmount(), 500 * 1e18, "Total staked supply should be 500");
    }

    function testUnstake() public {
        // Mint some tokens to the user's address
        vm.startPrank(deployer);
        sabreDAO.mint(user, 500 * 1e18);

        vm.stopPrank();
        console.log(sabreDAO.balanceOf(user), "user balance");
        // Approve the SabreDAOStaking contract to spend tokens on behalf of the user
        // Approve the SabreDAOStaking contract to spend tokens on behalf of the SabreDAO contract
        // vm.startPrank(deployer);
        // sabreDAO.approve(address(staking), 1000 * 1e18); // Ensure this is done before staking
        // vm.stopPrank();

        // Stake 500 tokens
        vm.startPrank(user);
        sabreDAO.approve(address(staking), 500 * 1e18);
        staking._stake(500 * 1e18);
        vm.stopPrank();

        vm.startPrank(user);
        sabreDAO.approve(address(user), 500 * 1e18);
        console.log(sabreDAO.balanceOf(user), "user balance");
        console.log(sabreDAO.balanceOf(address(staking)), "stake balance");
        staking._unStake(500 * 1e18);
        console.log(sabreDAO.balanceOf(user), "user balance after unstake");
        vm.stopPrank();
        console.log(staking.sm_balance(user), "mapping value");

        console.log(staking._getTotalStakedAmount(), "state-Variable storage");
        assertEq(staking._getStake(user), 0);
        assertEq(staking._getTotalStakedAmount(), 0);
    }

    // function testUpdateReward() public  {

    // }
    // function testEarn() public {

    // }
    function testMoreThanZero() public {
        vm.startPrank(user);
        uint256 amount = 0;
        vm.expectRevert();
        staking._stake(amount);

        vm.stopPrank();
    }

    function testAPY() public {
        // Set up initial conditions
        uint256 initialTime = block.timestamp;
        uint256 expectedYears = 1; // Assuming you want to test for 1 year
        uint256 expectedAPY = 10; // Assuming an annual rate of 20%
        // uint expectedCompoundInterest = 12; // Assuming a compound interest rate of 12 times per year

        // Calculate the expected APY value
        // uint expectAPYValue = (1 + (expectedAPY / expectedCompoundInterest)) ** ( expectedCompoundInterest * expectedYears) - 1;
        uint256 expectedAPYValue = (expectedYears * expectedAPY);

        // Simulate the passage of time
        vm.warp(initialTime + 31536000); // Warp forward by 1 year in seconds

        // Call the APY function
        uint256 actualAPYValue = staking.APY(_investedTime);
        console.log(actualAPYValue, "actual APY value");
        console.log(expectedAPYValue, "expected APY value");

        // Assert that the actual APY value matches the expected value
        assertEq(actualAPYValue, expectedAPYValue, "APY calculation does not match expected value");
    }

    function testReward() public {
        // staking my to update the sm_balance
        vm.startPrank(deployer);
        sabreDAO.mint(user, 1000 * 1e18);

        vm.stopPrank();
        // Approve the SabreDAOStaking contract to spend tokens on behalf of the user

        console.log(sabreDAO.balanceOf(address(sabreDAO)), "sabreDAO amount");

        // Stake 500 tokens
        vm.startPrank(user);
        sabreDAO.approve(address(staking), 1000 * 1e18);
        staking._stake(500 * 1e18);
        vm.stopPrank();

        uint256 expectStakeAmt = 500 * 1e18;
        uint256 expectAPY = 10;

        uint256 expectTotalReward = expectStakeAmt * expectAPY;
        console.log(expectTotalReward, "expectTotalReward");

        uint256 expertUserReward = (expectStakeAmt * expectTotalReward) / (expectStakeAmt * 100000);
        console.log(expertUserReward, "expertUserReward");
        //actual factors
        uint256 actualUserReward = staking.rewardAndAPY(user, _investedDayTime);
        console.log(actualUserReward, expertUserReward, "actual user reward");
        assertEq(actualUserReward, expertUserReward);
    }

    function testClaimReward() public {
        vm.startPrank(deployer);
        sabreDAO.mint(user, 1000 * 1e18);

        vm.stopPrank();
        // Approve the SabreDAOStaking contract to spend tokens on behalf of the user

        console.log(sabreDAO.balanceOf(address(sabreDAO)), "sabreDAO amount");

        // Stake 500 tokens
        vm.startPrank(user);
        sabreDAO.approve(address(staking), 1000 * 1e18);
        staking._stake(500 * 1e18);
        vm.stopPrank();

        uint256 expectStakeAmt = 500 * 1e18;
        uint256 expectAPY = 10;

        uint256 expectTotalReward = expectStakeAmt * expectAPY;
        console.log(expectTotalReward, "expectTotalReward");

        uint256 expertUserReward = (expectStakeAmt * expectTotalReward) / (expectStakeAmt * 100000);
        console.log(expertUserReward, "expertUserReward");
        //actual factors
        uint256 actualUserReward = staking.rewardAndAPY(user, _investedDayTime);
        console.log(actualUserReward, expertUserReward, "actual user reward");

        ///////////////
        //claim reward//
        ///////////////
        console.log(sabreDAO.balanceOf(address(staking)));
        uint256 expectedClaimreward = actualUserReward;
        assertEq(staking.getClaimReward(user), expectedClaimreward);
    }

    function testGetStake() public {
        // Setup: Mint tokens to the user and approve the staking contract
        vm.startPrank(deployer);
        sabreDAO.mint(user, 1000 * 1e18);
        vm.stopPrank();

        // Approve the staking contract to spend tokens on behalf of the user
        vm.startPrank(user);
        sabreDAO.approve(address(staking), 1000 * 1e18);
        vm.stopPrank();

        // Stake 500 tokens
        vm.startPrank(user);
        staking._stake(500 * 1e18);
        vm.stopPrank();

        // Test: Assert that the _getStake function returns the correct staked amount
        uint256 stakedAmount = staking._getStake(user);
        assertEq(stakedAmount, 500 * 1e18, "User's staked amount should be 500 tokens");
    }

    function testGetTotalStakedAmount() public {
        // Setup: Mint tokens to the user and approve the staking contract
        vm.startPrank(deployer);
        sabreDAO.mint(user, 1000 * 1e18);
        vm.stopPrank();

        // Approve the staking contract to spend tokens on behalf of the user
        vm.startPrank(user);
        sabreDAO.approve(address(staking), 1000 * 1e18);
        vm.stopPrank();

        // Stake 500 tokens
        vm.startPrank(user);
        staking._stake(500 * 1e18);
        vm.stopPrank();

        // Test: Assert that the _getTotalStakedAmount function returns the correct total staked amount
        uint256 totalStakedAmount = staking._getTotalStakedAmount();
        assertEq(totalStakedAmount, 500 * 1e18, "Total staked amount should be 500 tokens");
    }
}
