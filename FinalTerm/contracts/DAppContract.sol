// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./TRY.sol";

contract DAppContract is TRY {

    uint public value;

    constructor() TRY(uint(100)) {
        value = 1;
    }

    function startRound() public {
        startNewRound();
    }

    function endRound() public {
        closeRound();
    }

    function endLottery() public {
        closeLottery();
    }

    function buyTicket() public {
        //buy([uint(1),2,3,4,5], 6);
        emit StartRound();
    }
}