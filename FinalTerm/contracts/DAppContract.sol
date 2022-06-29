// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./TRY.sol";

contract DAppContract{

    address public lotteryManager;
    TRY contractTRY;

    constructor(){
    }

    function startLottery() public{
        contractTRY = new TRY();
        lotteryManager = msg.sender;
    }

    function startRound() public {
        //contracts[id].startNewRound();
    }

    function endRound() public {
        //closeRound();
    }

    function endLottery() public {
        //closeLottery();
    }

    function buyTicket() public {
        //buy([uint(1),2,3,4,5], 6);
        //emit StartRound();
    }
}