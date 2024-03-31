# How to execute

To execute the project the following commands are needed: 

First of all it is needed to start Ganache blockchain: 

```ganache -p 8545```

After that, the following commands compile the smart contract

```truffle compile```

and then deploy that on the Ganache blockchain with

```truffle migrate --reset```

Finally, the application is started with the command 

```npm run dev```
