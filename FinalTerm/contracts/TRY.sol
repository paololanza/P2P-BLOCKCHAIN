// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./NFTManager.sol";

contract TRY{

    //create a structure ticket
    struct Ticket {
        address buyer;
        uint[5] numbers;
        uint powerball;
    }

    uint constant K = 32; 
    uint blockClosed; //last block in which the lottery is open
    uint M; //block duration (given by parameter in constructor)
    address[] users; //user list
    Ticket[] tickets; //user's tickets
    bool activeRound; //true if a round is active, false otherwise
    address lottery_manager; //lottery manager address
    uint ticket_price = 1000000000000000000; //1 eth
    NFTManager NFT;

    event StartRound();
    event TicketBought(address buyer, uint[5] number, uint powerball);
    event Draw(uint[6] numbers);
    event TicketWinner(address buyer, uint class);
    event EndRound();
    event endLottery();

    constructor(uint _M){
        activeRound = true;
        lottery_manager = msg.sender;
        M = _M;
        blockClosed = block.number + M; 
        NFT =  new NFTManager();

        for(uint i = 0; i < 8; i++)
        {
            mint(i);
        }

        emit StartRound();
    }

    function startNewRound() 
        public
    {
        require(lottery_manager == msg.sender, "You're not the lottery manager");
        require(activeRound == false, "Round already started!");

        //reset the new closed block
        blockClosed = block.number + M;

        activeRound = true;
        emit StartRound();
    }

    function buy(uint[5] memory _numbers, uint _powerball) 
        public
        payable
    {

        //check if the round is activeRound
        require(activeRound == true, "Lottery closed");
        require(blockClosed > block.number, "Lottery closed");
        
        //check if the value is enough to buy a ticket
        uint money = msg.value;
        require(money >= ticket_price, "Value too small");

        //check if the numbers are correct
        require(_numbers.length == 5, "Insert 5 number");
        require(_powerball >= 1 && _powerball <= 26, "Insert a correct value for powerball");
        for(uint i = 0; i < _numbers.length; i++)
            require(_numbers[i] >= 1 && _numbers[i] <= 69, "Insert a correct value for numbers");

        //create an istance of ticket
        Ticket memory ticket = Ticket({buyer : msg.sender, numbers : _numbers, powerball : _powerball});
        tickets.push(ticket);

        //give the change to buyer
        if(money > ticket_price)
            payable(msg.sender).transfer(money - ticket_price);

        emit TicketBought(msg.sender, _numbers, _powerball);
    }

    function drawNumbers()
        internal
        returns(uint256[6] memory)
    {
        require(lottery_manager == msg.sender, "You're not the lottery manager");
        require(blockClosed <= block.number, "Lottery not yet closed");

        uint256[6] memory expandedValues;
        uint blockNumber = block.number + K;
        uint previous = 0;

        for (uint256 i = 0; i < 6; i++) 
        {   
            if (i != 5)
                expandedValues[i] = (uint256(keccak256(abi.encode(blockNumber, previous))) % 69) + 1;
            else
                expandedValues[i] = (uint256(keccak256(abi.encode(blockNumber, previous))) % 29) + 1;

            for(uint j = 0; j < i; j++)
                if (expandedValues[j] == expandedValues[i])
                    i--;

            previous = expandedValues[i];
        }

        emit Draw(expandedValues);

        return expandedValues;
    }

    function givePrizes()
        internal
    {
        require(lottery_manager == msg.sender, "You're not the lottery manager");
        require(blockClosed <= block.number, "Lottery not yet closed");
        
        uint256[6] memory drawNumber = drawNumbers();

        for(uint t = 0; t < tickets.length; t++)
        {
            uint numberCount = 0;
            uint powerball = 0;
            if(tickets[t].powerball == drawNumber[5])
                powerball = 1;
            for(uint i = 0; i < 5; i++)
                for(uint j = 0; j < 5; j++)
                    if(tickets[t].numbers[i] == drawNumber[j])
                        numberCount++;
            
            uint class = getClass(numberCount, powerball);

            //case in which the user has won the lottery
            if(class != 0)
            {
                //assign the NFT
                NFT.assignNFT(tickets[t].buyer, class);

                //mint new NFT of the same class
                mint(class);

                //emit the WinnerTicket event
                emit TicketWinner(tickets[t].buyer, class);
            }
        }
    }

    function mint(uint class) 
        internal
    {
        require(lottery_manager == msg.sender, "You're not the lottery manager");

        NFT.mintNFT(class);
    }

    function closeLottery()
        public
        payable
    {
        require(lottery_manager == msg.sender, "You're not the lottery manager");

        if(blockClosed > block.number)
            //refund the ticket_price 
            for(uint i = 0; i < tickets.length; i++)
                payable(tickets[uint(i)].buyer).transfer(ticket_price);

        emit endLottery();

        //destruct the contract
        selfdestruct(payable(lottery_manager));
    }

    function closeRound()
        public
        payable
    {
        require(lottery_manager == msg.sender, "You're not the lottery manager");
        require(activeRound == true, "Round already closed!");
        require(blockClosed < block.number, "Round not yet finished!");

        //give prizes to users
        givePrizes();

        //give the current contract balance to the lottery manager
        payable(lottery_manager).transfer(address(this).balance);

        //delete all the tickets bought in this round
        delete tickets;

        activeRound = false;
        emit EndRound();
    }

    function getClass(uint number, uint powerball) 
        internal
        returns(uint) 
    {
        if(number == 0 && powerball == 1)
            return uint(8);
        else  
            if(number == 1)
                return uint(8 - (number + powerball));
            else
                if(number == 2)
                    return uint(8 - (number + powerball));
                else
                    if(number == 3)
                        return uint(8 - (number + powerball));
                    else
                        if(number == 4)
                            return uint(8 - (number + powerball));
                        else
                            if(number == 5 && powerball == 0)
                                return uint(2);
                            else
                                if(number == 5 && powerball == 1)
                                    return uint(1);
                                else
                                    return uint(0);
    }
}