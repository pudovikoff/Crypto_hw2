// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract BoxImplementation is UUPSUpgradeable {
    uint256 private _value;
    
    function setValue(uint256 newValue) public {
        _value = newValue;
    }
    
    function getValue() public view returns (uint256) {
        return _value;
    }
    
    function version() public pure virtual returns (string memory) {
        return "v1";
    }
    
    function _authorizeUpgrade(address) internal override view {
        // This will be handled by the proxy
    }
} 