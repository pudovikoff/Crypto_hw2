// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/BoxImplementationV2.sol";
import "../test/VersionControlledProxy.t.sol";

contract UpgradeScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementation
        BoxImplementationV2 implementationV2 = new BoxImplementationV2();
        
        // Upgrade proxy to new implementation
        TestVersionControlledProxy proxy = TestVersionControlledProxy(proxyAddress);
        proxy.upgradeTo(address(implementationV2));
        
        vm.stopBroadcast();
        
        console.log("BoxImplementationV2 deployed at:", address(implementationV2));
        console.log("Proxy upgraded to V2");
    }
} 