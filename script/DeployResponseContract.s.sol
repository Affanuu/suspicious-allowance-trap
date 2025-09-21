// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ResponseContract.sol";

contract DeployResponseContract is Script {
    function run() external {
        vm.startBroadcast();
        
        ResponseContract response = new ResponseContract();
        
        console.log("ResponseContract deployed at:", address(response));
        
        vm.stopBroadcast();
    }
}
