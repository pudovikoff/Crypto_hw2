// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/BoxImplementation.sol";
import "../test/VersionControlledProxy.t.sol";

contract DeployScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy implementation V1
        BoxImplementation implementation = new BoxImplementation();

        // Deploy proxy with implementation
        TestVersionControlledProxy proxy = new TestVersionControlledProxy(address(implementation));

        vm.stopBroadcast();

        console.log("BoxImplementation deployed at:", address(implementation));
        console.log("VersionControlledProxy deployed at:", address(proxy));
    }
}
