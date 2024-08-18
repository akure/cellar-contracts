// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {PriceRouter} from "src/modules/price-router/PriceRouter.sol";
import {IChainlinkAggregator} from "src/interfaces/external/IChainlinkAggregator.sol";
import {SepoliaAddresses} from "test/resources/Sepolia/SepoliaAddresses.sol";
/**
* @notice An example of adding a price asset to the price router.
* command ->  source .env && forge script script/Sepolia/AddBTCToPriceRouter.s.sol:AddBTCToPriceRouter --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
*
**/
contract AddBTCToPriceRouter is Script, SepoliaAddresses {
    address public constant OWNER = 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5;
    address public constant REGISTRY = 0x484024aCbE5e5Bf5493bE14f43721481A2CF38DB;
    address public constant PRICE_ROUTER = 0x38Bc18f1e115d235E7D921eC41780b0c8244414F;


    uint8 public constant CHAINLINK_DERIVATIVE = 1;

    function run() external {
        vm.startBroadcast();
        // Add pricing.
        PriceRouter.ChainlinkDerivativeStorage memory stor;
        PriceRouter.AssetSettings memory settings;
        // Initialize PriceRouter contract
        PriceRouter priceRouter = PriceRouter(PRICE_ROUTER);

        uint256 price = uint256(IChainlinkAggregator(BTC_USD_FEED).latestAnswer());
        console.log("Fetched price from Chainlink feed (BTC/USD):", price);
        settings = PriceRouter.AssetSettings(CHAINLINK_DERIVATIVE, BTC_USD_FEED);

        console.log("AssetSettings for BTC:");
        console.log("  derivative:", settings.derivative);
        console.log("  source:", settings.source);

        priceRouter.addAsset(BTC, settings, abi.encode(stor), price);
        console.log("Added BTC asset to PriceRouter");


        // Verify the addition of BTC
        uint256 retrievedPrice = priceRouter.getPriceInUSD(BTC);
        console.log("BTC price added and retrieved from PriceRouter:", retrievedPrice / 1e8);

        vm.stopBroadcast();
    }
}
/*
Expected output -
cellar-contracts$ source .env && forge script script/Sepolia/AddBTCToPriceRouter.s.sol:AddBTCToPriceRouter --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
[⠢] Compiling...
[⠢] Compiling 2 files with Solc 0.8.21
[⠰] Solc 0.8.21 finished in 2.90s
Compiler run successful!
Script ran successfully.

== Logs ==
  Fetched price from Chainlink feed (BTC/USD): 5984320765000
  AssetSettings for BTC:
    derivative: 1
    source: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
  Added BTC asset to PriceRouter
  BTC price added and retrieved from PriceRouter: 59843

## Setting up 1 EVM.

==========================

Chain 11155111

Estimated gas price: 0.014932495 gwei

Estimated total gas used for script: 136596

Estimated amount required: 0.00000203971908702 ETH

==========================

##### sepolia
✅  [Success]Hash: 0x367f612c00fab2db72fa1f1f120c303f4027d09d49385ae6429831f9e96298f5
Block: 6525410
Paid: 0.000001388176759198 ETH (98894 gas * 0.014037017 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.000001388176759198 ETH (98894 gas * avg 0.014037017 gwei)


==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Transactions saved to: /home/ak/somm/c2/cellar-contracts/broadcast/AddBTCToPriceRouter.s.sol/11155111/run-latest.json

Sensitive values saved to: /home/ak/somm/c2/cellar-contracts/cache/AddBTCToPriceRouter.s.sol/11155111/run-latest.json

*/