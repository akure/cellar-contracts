// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface IPriceRouter {
    function getPriceInUSD(address asset) external view returns (uint256);
}
/**
* @notice  source .env && forge script script/Sepolia/GetBTCPriceFromPriceRouter.s.sol:GetBTCPrice --rpc-url $ETHEREUM_SEPOLIA_RPC_URL  --broadcast
**/
contract GetBTCPrice is Script {
    // address constant WETH_ADDRESS = 0x5f207d42F869fd1c71d7f0f81a2A67Fc20FF7323;
    address constant BTC_ADDRESS = 0x0f86141Ff41F397602AD169b59dbe6f318987234;
    // address constant PRICE_ROUTER_ADDRESS = YOUR_PRICE_ROUTER_CONTRACT_ADDRESS;
    // TODO 
    address constant PRICE_ROUTER_ADDRESS = 0x38Bc18f1e115d235E7D921eC41780b0c8244414F;


    function run() external {
        vm.startBroadcast();

        IPriceRouter priceRouter = IPriceRouter(PRICE_ROUTER_ADDRESS);
        uint256 btcPriceInUsd = priceRouter.getPriceInUSD(BTC_ADDRESS);

        console.log("The price of BTC in USD is:", btcPriceInUsd / 1e8);

        vm.stopBroadcast();
    }
}

/* Expected output -
source .env && forge script script/Sepolia/GetBTCPriceFromPriceRouter.s.sol:GetBTCPrice --rpc-url $ETHEREUM_SEPOLIA_RPC_URL  --broadcast
[⠢] Compiling...
[⠢] Compiling 1 files with Solc 0.8.21
[⠆] Solc 0.8.21 finished in 840.73ms
Compiler run successful!
Script ran successfully.

== Logs ==
  The price of DAI in USD is: 59843
*/