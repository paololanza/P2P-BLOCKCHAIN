App = {

    contracts: {},
    web3Provider: null,             // Web3 provider
    url: 'http://localhost:8545',   // Url for web3
    account: '0x0',                 // current ethereum account

    init: function() {

        return App.initWeb3();
    },

    /* initialize Web3 */
    initWeb3: function() {
        console.log("Entered")
        
        if(typeof web3 != 'undefined') {
            App.web3Provider = window.ethereum; 
            web3 = new Web3(App.web3Provider);
            try {
                    ethereum.enable().then(async() => {
                        console.log("DApp connected to Metamask");
                    });
            }
            catch(error) {
                console.log(error);
            }
        } else {
            App.web3Provider = new Web3.providers.HttpProvider(App.url);
            web3 = new Web3(App.web3Provider);
        }

        return App.initContract();
    },

    /* Upload the contract's abstractions */
    initContract: function() {
        $("#alert").hide();

        // Get current account
        web3.eth.getCoinbase(function(err, account) {
            if(err == null) {
                App.account = account;
                localStorage.setItem("addressID", account);
                $("#accountId").html("Your address: " + account);
            }
        });

        // Load content's abstractions
        $.getJSON("TRY.json").done(function(c) {
            App.contracts["Contract"] = TruffleContract(c);
            App.contracts["Contract"].setProvider(App.web3Provider);

            setInterval(App.actualBlock(), 5*1000);

            return App.listenForEvents();
        });
    },

    //shows an alert on the user interface
    showAlert: function (message) {
        $("#message").html(message);
        $("#alert").fadeTo(3000, 500).slideUp(500, function() {
          $("#alert").slideUp(500);
        });
    },

    //event listener that catch the events emitted from the contract
    listenForEvents: function() {

        App.contracts["Contract"].deployed().then(async (instance) => {

                instance.StartLottery().on('data', function (event) {  
                    console.log(event);

                    //send notification to all users
                    if(App.account != localStorage.getItem("lotteryManager"))
                    {
                        App.notification("Lottery Started!");
                        self.location = "./indexUser.html";
                    }
                    else
                    {
                        self.location = "./indexManager.html";
                    }
                })
                
                instance.StartRound().on('data', function (event) {

                    //send a notification to all users
                    if(App.account != localStorage.getItem("lotteryManager"))
                        App.notification("New Lottery Round Started!");

                    console.log(event);
                })

                instance.TicketBought().on('data', function (event) {
                    var address = event.returnValues['0'];

                    //send a feedback only to user that bought the ticket
                    if(App.account == address.toLowerCase())
                        App.showAlert(address + ": ticket bought correctly!");       

                    console.log(event);
                });

                instance.Draw().on('data', function (event) {
                    console.log(event);
                });
                
                instance.TicketWinner().on('data', function (event) {
                    var address = event.returnValues['0'];
                    var classe = event.returnValues['1'];

                    //check if the user has won the lottery
                    if(App.account == address.toLowerCase())
                        App.notification("Congratulation " + address + ", you have won a class " + classe + " NFT!"); 

                    console.log(event);
                });

                instance.EndRound().on('data', function (event) {
                    //show an alert to all users
                    App.showAlert("Lottery round ended");
                    console.log(event);
                });

                instance.EndLottery().on('data', function (event) {
                    //send a notification to all users
                    self.location = "./indexClosed.html";
                    localStorage.setItem("deactivateLottery", "true");
                    App.notification("Lottery ended!");
                    console.log(event);
                });
        });

        return App.render();
    },
    
    render: function() {

        App.contracts["Contract"].deployed().then(async(instance) =>{

            //show on the interface who is the lottery manager
            const v = await instance.lottery_manager(); 
            $("#lotteryManager").html("Lottery Manager:" + v);
            localStorage.setItem("lotteryManager", v.toLowerCase());
        });

        App.contracts["Contract"].deployed().then(async(instance) =>{

            //show on the user interface the round status
            const v = await instance.activeRound();
            localStorage.setItem("activeRound", v);
            var s;
            if(v == true)
                s = "active";
            else
                s = "finished";
            $("#activeRound").html("Round Status: " + s);
        });

        App.contracts["Contract"].deployed().then(async(instance) =>{

            //show on the user interface the lottery status
            const v = await instance.activeLottery();
            localStorage.setItem("activeLottery", v);
            var s;
            console.log(v);
            if(v == true)
                s = "active";
            else
                s = "not started";
            $("#activeLottery").html("Lottery Status: " + s);
        });

        App.contracts["Contract"].deployed().then(async(instance) =>{

            const v = await instance.deactivateLottery();
            localStorage.setItem("deactivateLottery", v);
        });

        App.contracts["Contract"].deployed().then(async(instance) =>{
            //show on the user interface the closure block
            const v = await instance.blockClosed();
            $("#closedblock").html("Closed Block: " + v.toNumber());
            localStorage.setItem("closedBlock", v);
        });

        App.contracts["Contract"].deployed().then(async(instance) =>{
            //show the last drawn numbers
            for(i = 0; i < 6; i++)
            {
                const v = await instance.lastDraw(i);
                $("#w"+i).html("" + v);
            }
        });


    },

    ////function that call the startLottery transaction in TRY.sol
    startLottery: function() {

        if(localStorage.getItem("activeLottery") == "true")
        {
            App.showAlert("Lottery already started!");
        }

        App.contracts["Contract"].deployed().then(async(instance) =>{

            await instance.startLottery(document.getElementById("lotteryBlock").value, {from: App.account});
        });
    
        
    },

    //function that call the startNewRound transaction in TRY.sol
    startRound: function() {
        if(localStorage.getItem("activeRound") == "true")
        {
            App.showAlert("Lottery round already started!");
            return;
        }

        App.contracts["Contract"].deployed().then(async(instance) =>{

            await instance.startNewRound({from: App.account});
        });
    },

    //function that call the closeRound transaction in TRY.sol
    endRound: function() {
        
        if(parseInt(localStorage.getItem("closedBlock")) > parseInt(localStorage.getItem("actualBlock")))
        {
            App.showAlert("Lottery round not yet finished!");
            return;
        }
        if(localStorage.getItem("activeRound") == "false")
        {
            App.showAlert("Lottery round already closed!");
            return;
        }

        App.contracts["Contract"].deployed().then(async(instance) =>{

            await instance.closeRound({from: App.account});
        });
    },

    //function that call the closeLottery transaction in TRY.sol
    endLottery: function() {

        App.contracts["Contract"].deployed().then(async(instance) =>{
            await instance.closeLottery({from: App.account});
        });
    },

    //function that call the buy transaction in TRY.sol
    buyTicket: function() {
        if(parseInt(localStorage.getItem("closedBlock")) <= parseInt(localStorage.getItem("actualBlock")))
        {
            App.showAlert("Lottery round finished!");
            return;
        }

        App.contracts["Contract"].deployed().then(async(instance) =>{
            const numArray = Array(5);
            const numbers = document.getElementsByName("array");
            for(i=0; i < 5;i++)
            {
                if(numbers[i].value > 69)
                {
                    $("#message").html("Invalid Number!");
                    $("#alert").fadeTo(3000, 500).slideUp(500, function() {
                        $("#alert").slideUp(500);
                    });
                    return;
                }
                else
                {
                    numArray[i] = numbers[i].value;
                }
            }

            if(numbers[5].value >= 29)
            {
                $("#message").html("Invalid numbers");
                $("#alert").fadeTo(3000, 500).slideUp(500, function() {
                    $("#alert").slideUp(500);
                });
                return;
            }
            await instance.buy(numArray, numbers[5].value, {from: App.account, value: 1000000000000000000});
        });
    },

    showNotification: function(_body) {
        //show the notification
        const notification = new Notification("TRY Lottery!", {
            body:_body
        });
    },

    //function that manage the notification permission
    notification: function(body){
        console.log(Notification.permission);
        if (Notification.permission === "granted")
        {
            App.showNotification(body);
        }
        else if (Notification.permission !== "denied")
        {
            Notification.requestPermission().then(permission => App.showNotification(body));
        }
        else
        {
            App.showNotification(body);
        }
    },

    //function that takes the actual block number
    actualBlock: function(){
        web3.eth.getBlockNumber().then(block => {
            $("#actualblock").html("Actual Block: " + block);
            localStorage.setItem("actualBlock", block);
        });
    } 

}

//call init whenever the window loads
$(function() {
    $(window).on('load', function () {
        App.init();
    });
});