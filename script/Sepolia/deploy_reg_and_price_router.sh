
#.env ->
#ETHEREUM_SEPOLIA_RPC_URL=Your_URL
#PRIVATE_KEY=0xYOUR_ADDRESS
#ETHERSCAN_KEY=YOUR_KEYS


cd ../../

source .env && forge script script/Sepolia/DeployPriceRouter.s.sol:DeployPriceRouterScript --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast  --slow

