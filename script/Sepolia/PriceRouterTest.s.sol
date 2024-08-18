// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface IPriceRouter {
    function getPriceInUSD(address asset) external view returns (uint256);
}

contract GetWethPrice is Script {
    address constant WETH_ADDRESS = 0x5f207d42F869fd1c71d7f0f81a2A67Fc20FF7323;
    // address constant PRICE_ROUTER_ADDRESS = YOUR_PRICE_ROUTER_CONTRACT_ADDRESS;
    // TODO 
    address constant PRICE_ROUTER_ADDRESS = 0x694AA1769357215DE4FAC081bf1f309aDC325306;


    function run() external {
        vm.startBroadcast();

        IPriceRouter priceRouter = IPriceRouter(PRICE_ROUTER_ADDRESS);
        uint256 wethPriceInUsd = priceRouter.getPriceInUSD(WETH_ADDRESS);

        console.log("The price of DAI in USD is:", wethPriceInUsd / 1e8);

        vm.stopBroadcast();
    }
}
