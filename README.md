

# __Lottery Game__

## Instructions

1. Clone repo to your local
2. Cd to repo, run:
    - npm install
    - npm run start
3. Open website: http://localhost:3000/ [port: based on your local]
4. You are player. Cannot stop the game.

## How To Test (only using)

1. Go to: https://testnet.binance.org/faucet-smart to request 0.2 BNB as fee transaction.
2. You MUST claim, erc20 token from my faucet(OR can use your ERC20 - testnet, see at Deployment Contract).
3. Approve/Betting: when your account NOT approve yet, so you should be approve first, then Betting.
4. You can see your `Number Ticket` on website - if you are `admin`, you cannot play the game.
5. Waiting result, when Admin is `stopped` the game.
5.1 (option); Only admin CAN stop the game


## Deployment Contract(You are own)
1. You MUST prepare your ERC20 address, deploy them, or USING my faucet.
2. Copy `.env.template` to `.env`, and insert your `private-key` to deploy.
3. Run: 
    ```
    truffle mirgrate --network testnet
    ```
    deploy contract `lottery` to `testnet`. Copy this address to `src/config.js` replace `LotteryAddr` (you can change your ERC20 token at step 1 - if use your token).
 4. Restart:
	 ```
	 npm run start
	 ```
5. Give link for player, and you can `STOP` the game whenever!

Please enjoy and have fun with `Lottery Game`!

## Contributor:
- [Dinh Mahone](https://github.com/dinhnt12)
