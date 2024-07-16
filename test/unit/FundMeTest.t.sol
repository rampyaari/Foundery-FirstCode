// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant FUND_SENT = 0.1 ether;
    uint256 constant INITIAL_ETHER = 10 ether;
    uint256 constant GAS_Price = 1;

    function setUp() external {
        fundMe = new DeployFundMe().run();
        vm.deal(USER, INITIAL_ETHER);
    } //this is used to deploy our contract in the test environment. This happens first

    function testMinimumDollarIsFine() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        console.log(fundMe.MINIMUM_USD());
    }

    function testOwnerIsMessageSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: FUND_SENT}();
        assertEq(address(fundMe.getFunderAddress(0)), USER);
        assertEq(fundMe.getAddressToAmountFunded(USER), FUND_SENT);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: FUND_SENT}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        // use this pattern - arrange, act, assert
        //arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //act
        //uint256 gasStart = gasleft();
        //vm.txGasPrice(GAS_Price);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //uint256 gasLeft = gasleft();
        //uint256 gasUsed = (gasStart - gasLeft) * tx.gasprice;

        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
        assertEq(endingFundMeBalance, 0);
    }

    function testWithdrawFromMultipleFunders() public funded {
        //arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), FUND_SENT);
            fundMe.fund{value: FUND_SENT}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //assert
        assertEq(address(fundMe).balance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        //arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), FUND_SENT);
            fundMe.fund{value: FUND_SENT}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //assert
        assertEq(address(fundMe).balance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            fundMe.getOwner().balance
        );
    }
}
