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
