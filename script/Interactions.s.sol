// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 private constant FUND_SENT = 0.01 ether;
    address USER = makeAddr("user");

    function fundFundMe(address _mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(_mostRecentDeployed)).fund{value: FUND_SENT}();
        vm.stopBroadcast();
        // console.log("Funded FundMe with %s", FUND_SENT);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address _mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(_mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        withdrawFundMe(mostRecentDeployed);
        vm.stopBroadcast();
    }
}
