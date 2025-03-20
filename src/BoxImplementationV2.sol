// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BoxImplementation.sol";

contract BoxImplementationV2 is BoxImplementation {
    // New state variable
    string private _message;

    function setMessage(string memory newMessage) public {
        _message = newMessage;
    }

    function getMessage() public view returns (string memory) {
        return _message;
    }

    function version() public pure virtual override returns (string memory) {
        return "v2";
    }
}
