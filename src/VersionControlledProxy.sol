// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract VersionControlledProxy is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    address[] public versionHistory;
    address public currentVersion;
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
    function initialize(address initialImplementation) public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        
        versionHistory.push(initialImplementation);
        currentVersion = initialImplementation;
    }
    
    function upgradeTo(address newImplementation) public override onlyOwner {
        require(newImplementation != address(0), "Invalid implementation address");
        require(newImplementation != currentVersion, "Already current version");
        
        versionHistory.push(newImplementation);
        currentVersion = newImplementation;
        
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }
    
    function rollbackTo(uint256 versionIndex) public onlyOwner {
        require(versionIndex < versionHistory.length, "Invalid version index");
        address targetVersion = versionHistory[versionIndex];
        require(targetVersion != currentVersion, "Already at this version");
        
        currentVersion = targetVersion;
        _upgradeToAndCallUUPS(targetVersion, new bytes(0), false);
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
    
    function _authorizeUpgrade(address) internal override onlyOwner {}
} 