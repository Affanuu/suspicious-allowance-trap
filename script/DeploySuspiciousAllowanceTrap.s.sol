// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/SuspiciousAllowanceTrap.sol";
import "../src/MockERC20.sol";

contract DeploySuspiciousAllowanceTrap is Script {
    function run() external {
        vm.startBroadcast();
        
        // Deploy a mock token for testing
        MockERC20 token = new MockERC20();
        
        // Deploy the trap contract with proper parameters
        SuspiciousAllowanceTrap trap = new SuspiciousAllowanceTrap(
            address(token),
            1000 ether
        );
        
        // Add test pairs with correct checksum addresses
        trap.addPair(0x742D35Cc9cC5027b4C3F8752928f1f0a8c1Fd8C5, 0x1234567890123456789012345678901234567890);
        
        console.log("MockERC20 deployed at:", address(token));
        console.log("SuspiciousAllowanceTrap deployed at:", address(trap));
        
        vm.stopBroadcast();
    }
}
