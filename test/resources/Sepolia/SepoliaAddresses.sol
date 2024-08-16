// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {CErc20} from "src/interfaces/external/ICompound.sol";

contract SepoliaAddresses {
    // Sommelier
    address public gravityBridgeAddress = 0xc85C2C535253b00bb687a0eE183FBDE6696Dbd32;
    address public strategist = 0xc85C2C535253b00bb687a0eE183FBDE6696Dbd32;
    address public devStrategist = 0xc85C2C535253b00bb687a0eE183FBDE6696Dbd32;
    address public cosmos = address(0xCAAA);
    address public deployerAddress = 0xc85C2C535253b00bb687a0eE183FBDE6696Dbd32;
    address public dev0Address = 0xc85C2C535253b00bb687a0eE183FBDE6696Dbd32;

    address public priceRouterV1 = 0x138a6d8c49428D4c71dD7596571fbd4699C7D3DA;
    address public priceRouterV2 = 0xA1A0bc3D59e4ee5840c9530e49Bdc2d1f88AaF92;
    address public ryusdAddress = 0x97e6E0a40a3D02F12d1cEC30ebfbAE04e37C119E;

    // DeFi Ecosystem
    address public ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public uniV3Router = 0x3bFA4769FB09eefC5a80d6E87c3B9C650f7Ae48E;
    address public uniV2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    // TODO = FIX FOR SEPOLIA 
    // Aave
    address public aaveV3Pool = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;
    address public aaveV3Oracle = 0xb56c2F0B653B2e0b10C9b928C8580Ac5Df02C7C7;

    
    // ERC20s
    ERC20 public USDC = ERC20(0x7Fc21ceb0C5003576ab5E101eB240c2b822c95d2);
    ERC20 public WETH = ERC20(0x5f207d42F869fd1c71d7f0f81a2A67Fc20FF7323);
    ERC20 public LINK = ERC20(0x779877A7B0D9E8603169DdbD7836e478b4624789);

    // Chainlink Automatoin
    address public automationRegistryV2 = 0x86EFBD0b6736Bed994962f9797049422A3A8E8Ad;
    address public automationRegistrarV2 = 0xb0E49c5D0d05cbc241d68c05BC5BA1d1B7B72976;
    // Chainlink Datafeeds
    address public WETH_USD_FEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    // Uniswap
    address public uniswapV3PositionManager = 0x1238536071E1c677A632429e3655c799b22cDA52;
    address public uniswapV3Factory = 0x0227628f3F023bb0B980b67D528571c95c6DaC1c;

    // Balancer
    address public vault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
}
