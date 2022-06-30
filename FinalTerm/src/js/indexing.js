function indexing()
{
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
