var loc = "";
if(localStorage.getItem("activeLottery") == "false" && 
   localStorage.getItem("lotteryManager") == localStorage.getItem("addressID"))
{
    loc = "/index.html";
}
else 
{
    if(localStorage.getItem("lotteryManager") == localStorage.getItem("addressID"))
    {
        loc = "/indexManager.html";
    }
    if(localStorage.getItem("lotteryManager") != localStorage.getItem("addressID"))
    {
        loc = "/indexUser.html";
    }
}
if(localStorage.getItem("deactivateLottery") == "true")
{
    loc = "/indexClosed.html";
}

if(loc != self.location.pathname.toString())
{
    self.location = loc;
}
