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

    uint DEBUG = 1;
    uint M; //block duration (given by parameter in constructor)
    uint K = 32;
    uint blockClosed; 
    address[] users; //user list
    Ticket[] public tickets; //user's tickets
    bool public activeRound; //true if a round is active, false otherwise
    address lottery_manager; //lottery manager address
    uint ticket_price = 10000000000000000; //1 eth
    NFTManager NFT;
    mapping(uint => uint) notAssignedNFT; //list of NFTs id that have not yet assigned
    mapping(uint => address) NFTMap; //NFT associated to user


    constructor(uint _M) public{
        activeRound = true;
        lottery_manager = msg.sender;
        M = _M;
        blockClosed = block.number + M;
        NFT =  new NFTManager();
        //mapMatchClass(matchClass);

        for(uint i = 0; i < 8; i++)
        {
            notAssignedNFT[i] = mint(i);
        }
    }

    function startNewRound() 
        public
    {
        require(lottery_manager == msg.sender, "You're not the lottery manager");
        require(activeRound == false, "Round already started!");
        activeRound == true;
        blockClosed = block.number + M;
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

        //check if the numbers are ok
        require(_numbers.length == 5, "Insert 5 number");
        require(_powerball >= 1 && _powerball <= 26, "Insert a correct value for powerball");
        for(uint i = 0; i < _numbers.length; i++)
            require(_numbers[i] >= 1 && _numbers[i] <= 69, "Insert a correct value for numbers");

        //create an istance of ticket type
        Ticket memory ticket = Ticket({buyer : msg.sender, numbers : _numbers, powerball : _powerball});
        tickets.push(ticket);

        //give the change to buyer
        if(money > ticket_price)
            payable(msg.sender).transfer(money - ticket_price);
    }

    function drawNumbers() 
    public
    returns(uint256[6] memory)
    {
        if(DEBUG == 1) 
            return [uint256(1),uint256(2),uint256(3),uint256(4),uint256(5),uint256(6)];

        uint256[6] memory expandedValues;
        uint blockNumber = block.number + K;
        require(lottery_manager == msg.sender, "You're not the lottery manager");

        for (uint256 i = 0; i < 6; i++) 
        {   
            if (i != 5)
                expandedValues[i] = (uint256(keccak256(abi.encode(blockNumber, i + 1))) % 69) + 1;
            else
                expandedValues[i] = (uint256(keccak256(abi.encode(blockNumber, i + 1))) % 29) + 1;

            //TODO: aggiungere controllo elemento già presente
        }
        return expandedValues;
    }

    function givePrizes() 
        public
        returns(uint)
    {
        require(lottery_manager == msg.sender, "You're not the lottery manager");
        
        uint256[6] memory drawNumber = drawNumbers();

        for(uint t = 0; t < tickets.length; t++)
        {
            uint numberCount = 0;
            uint powerball = 0;
            if(tickets[t].powerball == drawNumber[5])
                powerball = 1;
            for(uint i = 0; i < 6; i++)
                for(uint j = 0; j < 5; j++)
                    if(tickets[t].numbers[i] == drawNumber[j])
                        numberCount++;
            
            uint class = getClass(numberCount, powerball);

            //case in which the user has won the lottery
            if(class != 0)
            {
                //assign the NFT
                NFT.assignNFT(tickets[t].buyer, notAssignedNFT[class]);

                //mint new NFT of the same class
                notAssignedNFT[class] = mint(class);
            }
        }
    }

    function mint(uint class) 
        public
        returns(uint256)
    {
        require(lottery_manager == msg.sender, "You're not the lottery manager");

        uint256 NFTid = NFT.mintNFT(class);
        return NFTid;
    }

    function closeLottery() 
        public 
        payable
    {

        require(lottery_manager == msg.sender, "You're not the lottery manager");
        require(activeRound == true, "Round already closed!");

        if(blockClosed <= block.number)
            //give back the ticket_price 
            for(uint i = 0; i < tickets.length; i++)
                payable(tickets[uint(i)].buyer).transfer(ticket_price);
        else 
            payable(lottery_manager).transfer(tickets.length * ticket_price);

        activeRound = false;

        //TODO: resettare le strutture
    }

    function getClass(uint number, uint powerball) public returns(uint) {
        if(number == 0 && powerball == 1)
            return 8;  
        else  
            if(number == 1)
                return 8 - number + powerball;
            else
                if(number == 2)
                    return 8 - number + powerball;
                else
                    if(number == 3)
                        return 8 - number + powerball;
                    else
                        if(number == 4)
                            return 8 - number + powerball;
                        else
                            if(number == 5 && powerball == 0)
                                return 2;
                            else
                                if(number == 5 && powerball == 1)
                                    return 1;
                                else
                                    return 0;  
    }
}
