import networkx as nx
import pandas as pd

if __name__ == "__main__":
    #create a pandas dataframes from csv files
    input = pd.read_csv('inputs.csv')
    output = pd.read_csv('outputs.csv')
    transaction = pd.read_csv('transactions.csv')

    #for each transaction check if there's at least one input and output
    
    #for each transaction check if output is already present in UTXO

    #for each transaction check if input is unspent in UTXO

    
    
    