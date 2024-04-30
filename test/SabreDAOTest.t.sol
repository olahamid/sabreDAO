// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Test, console} from "./../lib/forge-std/src/Test.sol";

import {SabreDAO} from "./../src/SabreDAO.sol";
import {SabreDAOStaking} from "./../src/SabreDAOStaking.sol";
import {SabreDAOEngine} from "./../src/SabreDAOEngine.sol";

contract SabreDAOTest is Test {
    ////////////////////
    //    USERS    /////
    ////////////////////

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");

    ////////////////////////
    //    DATA/CONS    /////
    ////////////////////////

    ////////////////////
    // CONTRACTS   /////
    ////////////////////
    SabreDAO sabreDAO;
    SabreDAOStaking staking;
    SabreDAOEngine engine;

    ////////////////////
    // DEPLOY       /////
    ////////////////////

    function setUp() external {
        vm.startPrank(deployer);
        sabreDAO = new SabreDAO(deployer);

        vm.stopPrank();
    }

    function test_checkAddresses() external view {
        console.log("sabreDao: ", address(sabreDAO));
        console.log("real Total supply:      ", sabreDAO.totalSupply());
        assertEq(deployer, sabreDAO.owner());
    }

    //////////////////////////////
    // TESTS  FUNCIONALES     ///
    /////////////////////////////

    /*1. MINT AND BURN */

    function test_checkSimpleMint() external {
        vm.startPrank(deployer);
        sabreDAO.mint(deployer, 50 * 1e18);
        assertEq(110 * 1e18, sabreDAO.totalSupply());
        assertEq(100 * 1e18, sabreDAO.balanceOf(deployer));
    }

    function test_checkSimpleBurn() external {
        vm.startPrank(deployer);
        sabreDAO.burn(10 * 1e18);
        assertEq(40 * 1e18, sabreDAO.balanceOf(deployer));
    }

    function test_burnMoreThanBalance() external {
        vm.startPrank(deployer);
        vm.expectRevert();
        sabreDAO.burn(1000 * 1e18);
    }

    function test_mintToAddressZero() external {
        vm.startPrank(deployer);
        vm.expectRevert();
        sabreDAO.mint(address(0), 50 * 1e18);
    }
}
