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
        // console.log(web3);
        
        if(typeof web3 != 'undefined') {
//            App.web3Provider = web3.currentProvider;
//            web3 = new Web3(web3.currentProvider);
            App.web3Provider = window.ethereum; // !! new standard for modern eth browsers (2/11/18)
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
            App.web3Provider = new Web3.providers.HttpProvider(App.url); // <==
            web3 = new Web3(App.web3Provider);
        }

        return App.initContract();
    },

    /* Upload the contract's abstractions */
    initContract: function() {
        $("#alert").hide();
        localStorage.setItem("activeLottery", "false");
        localStorage.setItem("activeRound", "false");
        localStorage.setItem("deactivateLottery", "false");

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

            return App.listenForEvents();
        });
    },

    showAlert: function () {
        $("#alert").fadeTo(2000, 500).slideUp(500, function() {
          $("#alert").slideUp(500);
        });
    },

    // Write an event listener
    listenForEvents: function() {

        App.contracts["Contract"].deployed().then(async (instance) => {

            //web3.eth.getBlockNumber(function (error, block) {
                //
                instance.StartRound().on('data', function (event) {
                    self.location = "./indexManager.html";
                    $("#message").html("Lottery started");
                    $("#alert").fadeTo(3000, 500).slideUp(500, function() {
                        $("#alert").slideUp(500);
                      });

                    // If event has parameters: event.returnValues.valueName
                });

                instance.EndLottery().on('data', function (event) {
                    self.location = "./indexClosed.html";
                    $("#message").html("Lottery ended");
                    $("#alert").fadeTo(3000, 500).slideUp(500, function() {
                        $("#alert").slideUp(500);
                      });

                    // If event has parameters: event.returnValues.valueName
                });
             //});
        });

        return App.render();
    },

    // Get a value from the smart contract
    render: function() {

        App.contracts["Contract"].deployed().then(async(instance) =>{

            const v = await instance.lottery_manager(); 
            $("#lotteryManager").html("Lottery Manager:" + v);
            localStorage.setItem("lotteryManager", v.toLowerCase());
        });

        App.contracts["Contract"].deployed().then(async(instance) =>{

            const v = await instance.activeRound();
            $("#activeRound").html("" + v);
            localStorage.setItem("activeRound", v);
        });

        App.contracts["Contract"].deployed().then(async(instance) =>{

            const v = await instance.activeLottery();
            $("#activeLottery").html("" + v);
            localStorage.setItem("activeLottery", v);
        });

        App.contracts["Contract"].deployed().then(async(instance) =>{

            const v = await instance.deactivateLottery();
            localStorage.setItem("deactivateLottery", v);
        });
    },

    // Call a function from a smart contract
    // The function send an event that triggers a transaction:: Metamask opens to confirm the transaction by the user

    startLottery: function() {

        App.contracts["Contract"].deployed().then(async(instance) =>{

            await instance.startLottery(100, {from: App.account});
        });

        
    },

    startRound: function() {

        App.contracts["Contract"].deployed().then(async(instance) =>{

            await instance.startNewRound({from: App.account});
        });
    },

    endRound: function() {

        App.contracts["Contract"].deployed().then(async(instance) =>{

            await instance.closeRound({from: App.account});
        });
    },

    endLottery: function() {

        App.contracts["Contract"].deployed().then(async(instance) =>{
            await instance.closeLottery({from: App.account});
        });
    },

    buyTicket: function() {

        App.contracts["Contract"].deployed().then(async(instance) =>{

            await instance.buyTicket({from: App.account});
        });
    },

    showNotification: function() {
        const notification = new Notification("Lottery Started!", {
            body:"The lottery is started"
        });
    },

    notification: function(){
        console.log(Notification.permission);
        if (Notification.permission === "granted")
        {
            showNotification();
        }
        else if (Notification.permission !== "denied")
        {
            Notification.requestPermission().then(permission => showNotification());
        }
        else
        {
            showNotification();
        }
    }

}

// Call init whenever the window loads
$(function() {
    $(window).on('load', function () {
        App.init();
    });
});

function indexing()
{
    /*if(localStorage.getItem("activeLottery") == "false" && 
       self.location.pathname != "/index.html")
    {
        self.location = "index.html";
    }*/
    //lotteria avviata 
    if(localStorage.getItem("lotteryManager") == localStorage.getItem("addressID") && 
            localStorage.getItem("activeLottery") == "true")
        {
            self.location = "indexManager.html";
        }
    if(localStorage.getItem("lotteryManager") != localStorage.getItem("addressID") &&
                localStorage.getItem("activeLottery") == "true")
        {
            self.location = "indexUser.html";
        }
    if(localStorage.getItem("deactivateLottery") == "true")
    {
        self.location = "indexClosed.html";
    }

}