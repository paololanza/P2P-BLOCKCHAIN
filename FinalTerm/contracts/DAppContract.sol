// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract DAppContract {

    uint public value;
    event click();

    constructor() {

        value = 42;
    }

    function pressClick() public {
        
        emit click();
    }
}