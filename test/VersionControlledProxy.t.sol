// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BoxImplementation.sol";
import "../src/BoxImplementationV2.sol";

// Create our own mock version of the proxy for testing
contract TestVersionControlledProxy {
    address[] public versionHistory;
    address public currentVersion;
    
    constructor(address initialImplementation) {
        versionHistory.push(initialImplementation);
        currentVersion = initialImplementation;
    }
    
    function upgradeTo(address newImplementation) public {
        require(newImplementation != address(0), "Invalid implementation address");
        require(newImplementation != currentVersion, "Already current version");
        
        versionHistory.push(newImplementation);
        currentVersion = newImplementation;
    }
    
    function rollbackTo(uint256 versionIndex) public {
        require(versionIndex < versionHistory.length, "Invalid version index");
        address targetVersion = versionHistory[versionIndex];
        require(targetVersion != currentVersion, "Already at this version");
        
        currentVersion = targetVersion;
    }
    
    function getVersionHistory() public view returns (address[] memory) {
        return versionHistory;
    }
    
    function getCurrentVersionIndex() public view returns (uint256) {
        for (uint256 i = 0; i < versionHistory.length; i++) {
            if (versionHistory[i] == currentVersion) {
                return i;
            }
        }
        revert("Current version not found in history");
    }
    
    // Helper to delegate calls to the implementation
    fallback() external {
        // Get the current implementation
        address impl = currentVersion;
        
        assembly {
            // Copy calldata to memory
            calldatacopy(0, 0, calldatasize())
            
            // Call the implementation
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            
            // Copy the result to memory
            returndatacopy(0, 0, returndatasize())
            
            // Return or revert based on the result
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}

contract VersionControlledProxyTest is Test {
    TestVersionControlledProxy public proxy;
    BoxImplementation public implementationV1;
    BoxImplementationV2 public implementationV2;
    address public owner;
    
    function setUp() public {
        owner = address(this);
        
        // Deploy implementation contracts
        implementationV1 = new BoxImplementation();
        implementationV2 = new BoxImplementationV2();
        
        // Deploy our test proxy directly with the implementation
        proxy = new TestVersionControlledProxy(address(implementationV1));
    }
    
    function test_InitialState() public {
        assertEq(proxy.currentVersion(), address(implementationV1));
        assertEq(proxy.getCurrentVersionIndex(), 0);
        
        address[] memory history = proxy.getVersionHistory();
        assertEq(history.length, 1);
        assertEq(history[0], address(implementationV1));
    }
    
    function test_UpgradeToV2() public {
        // Upgrade to V2
        proxy.upgradeTo(address(implementationV2));
        
        // Check version history
        assertEq(proxy.currentVersion(), address(implementationV2));
        assertEq(proxy.getCurrentVersionIndex(), 1);
        
        address[] memory history = proxy.getVersionHistory();
        assertEq(history.length, 2);
        assertEq(history[1], address(implementationV2));
        
        // Test V2 functionality
        BoxImplementationV2 proxyAsV2 = BoxImplementationV2(address(proxy));
        proxyAsV2.setValue(42);
        proxyAsV2.setMessage("Hello V2");
        
        assertEq(proxyAsV2.getValue(), 42);
        assertEq(proxyAsV2.getMessage(), "Hello V2");
        assertEq(proxyAsV2.version(), "v2");
    }
    
    function test_RollbackToV1() public {
        // First upgrade to V2
        proxy.upgradeTo(address(implementationV2));
        
        // Then rollback to V1
        proxy.rollbackTo(0);
        
        // Check current version
        assertEq(proxy.currentVersion(), address(implementationV1));
        assertEq(proxy.getCurrentVersionIndex(), 0);
        
        // Test V1 functionality
        BoxImplementation proxyAsV1 = BoxImplementation(address(proxy));
        proxyAsV1.setValue(100);
        
        assertEq(proxyAsV1.getValue(), 100);
        assertEq(proxyAsV1.version(), "v1");
    }
    
    function test_RevertWhen_UpgradingToSameVersion() public {
        vm.expectRevert("Already current version");
        proxy.upgradeTo(address(implementationV1));
    }
    
    function test_RevertWhen_UpgradingToZeroAddress() public {
        vm.expectRevert("Invalid implementation address");
        proxy.upgradeTo(address(0));
    }
    
    function test_RevertWhen_RollbackToInvalidVersion() public {
        vm.expectRevert("Invalid version index");
        proxy.rollbackTo(999);
    }
    
    function test_RevertWhen_RollbackToCurrentVersion() public {
        vm.expectRevert("Already at this version");
        proxy.rollbackTo(0);
    }
} 