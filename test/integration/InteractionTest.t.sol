// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        //vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        //WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        //withdrawFundMe.withdrawFundMe(address(fundMe));

        console.log(fundMe.getOwner());
        console.log(address(fundMe));
        console.log(fundMe.getFunderAddress(0));
        //console.log(fundMe.getFunderAddress(1));
        //console.log(USER);
        //console.log(fundMe.getOwner().balance);
        //console.log(USER.balance);

        //assert(address(fundMe).balance == 0);
    }
}
