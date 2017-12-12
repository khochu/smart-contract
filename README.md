# smart-contract

Hedgeable's Authorization Smart Contract

# Testing on Rinkeby Testnet

1. Deploy Smart Contract on the testnet through Ethereum Wallet.
    1. Make sure the central miner is the owner account address
    2. Set the contract address in the connector
2. Whitelist partner accounts through whitelist function
3. Give partner accounts hydro to send
4. Close Ethereum Wallet
5. Install geth
6. Download Rinkeby testnet (instructions https://gist.github.com/cryptogoth/10a98e8078cfd69f7ca892ddbdcf26bc)
7. Now run geth with the command:  geth --networkid=4 --datadir=$HOME/.rinkeby --cache=1024 --bootnodes=enode://a24ac7c5484ef4ed0c5eb2d36620ba4e4aa13b8c84684e1b4aab0cebea2ae45cb4d375b77eab56516d34bfbd3c1a833fc51296ff084b770b94fb9028c4d25ccf@52.169.42.101:30303 --rpc --rpcapi db,eth,net,web3,personal --rpcport 8545 --rpcaddr 127.0.0.1 --rpccorsdomain "*" 
8. Deploy the connector with:  mvn spring-boot:run 
9. Deploy the digital wealth api with:  mvn spring-boot:run -Dspring.profiles.active=hydro 
10. Call /authenticate/hyrdo/challenge to get the challenge string and required value
11. Send transaction to the contract from partner wallet with appropriate amount and string
12. Call /authenticate/hydro to receive your HydroToken
13. Use the api as usual while including the header token X-Hydro-Token

# Testing with Populus
- All changes made to HydroToken.sol must be ported over to HydroTokenTest.sol (Currently populus does not support create contracts with arguments so we must manually set the owner)
- Navigate to eh test folder in command line
- $ populus compile
- $ populus deploy --chain tester --no-wait-for-sync
- $ pytest tests/
