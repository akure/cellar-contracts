// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/console.sol";
import "forge-std/Script.sol";
// Import necessary contracts
import {Deployer} from "src/Deployer.sol";
import {Registry} from "src/Registry.sol";
import {PriceRouter} from "src/modules/price-router/PriceRouter.sol";
import {SequencerPriceRouter} from "src/modules/price-router/permutations/SequencerPriceRouter.sol";
import {ERC20Adaptor} from "src/modules/adaptors/ERC20Adaptor.sol";
import {SwapWithUniswapAdaptor} from "src/modules/adaptors/Uniswap/SwapWithUniswapAdaptor.sol";
import {UniswapV3PositionTracker} from "src/modules/adaptors/Uniswap/UniswapV3PositionTracker.sol";
import {UniswapV3Adaptor} from "src/modules/adaptors/Uniswap/UniswapV3Adaptor.sol";
import {AaveV3ATokenAdaptor} from "src/modules/adaptors/Aave/V3/AaveV3ATokenAdaptor.sol";
import {AaveV3DebtTokenAdaptor} from "src/modules/adaptors/Aave/V3/AaveV3DebtTokenAdaptor.sol";
import {ERC4626Adaptor} from "src/modules/adaptors/ERC4626Adaptor.sol";
import {OneInchAdaptor} from "src/modules/adaptors/OneInch/OneInchAdaptor.sol";
import {ZeroXAdaptor} from "src/modules/adaptors/ZeroX/ZeroXAdaptor.sol";
import {IChainlinkAggregator} from "src/interfaces/external/IChainlinkAggregator.sol";
import {UniswapV3Pool} from "src/interfaces/external/UniswapV3Pool.sol";
// import {ArbitrumAddresses} from "test/resources/Arbitrum/ArbitrumAddresses.sol";
import {SepoliaAddresses} from "test/resources/Sepolia/SepoliaAddresses.sol";
import {ContractDeploymentNames} from "resources/ContractDeploymentNames.sol";

import {PositionIds} from "resources/PositionIds.sol";
import {Math} from "src/utils/Math.sol";

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";

contract SetUpArchitectureScript is Script, SepoliaAddresses, ContractDeploymentNames, PositionIds {
    using Math for uint256;
    using stdJson for string;

    uint256 public privateKey;
    Deployer public deployer = Deployer(deployerAddress);
    Registry public registry;
    PriceRouter public priceRouter;
    address public erc20Adaptor;
    address public swapWithUniswapAdaptor;
    address public uniswapV3Adaptor;
    address public aaveV3ATokenAdaptor;
    address public aaveV3DebtTokenAdaptor;
    address public erc4626Adaptor;
    address public oneInchAdaptor;
    address public zeroXAdaptor;

    uint256 public constant AAVE_V3_MIN_HEALTH_FACTOR = 1.01e18;

    uint8 public constant CHAINLINK_DERIVATIVE = 1;
    uint8 public constant TWAP_DERIVATIVE = 2;
    uint8 public constant EXTENSION_DERIVATIVE = 3;

    constructor() {
        // Load environment variables
        privateKey = vm.envUint("PRIVATE_KEY");
        console.log("Loaded private key:", privateKey);
    }

    function setUp() external {
        privateKey = vm.envUint("PRIVATE_KEY");
    }

    function run() external {
        console.log("Running deployment script...");
        bytes memory creationCode;
        bytes memory constructorArgs;
        
        /*
        try vm.createSelectFork("sepolia") returns (uint256 forkId) {
            console.log("Fork created with ID:", forkId);
        } catch Error(string memory reason) {
            console.log("Error creating fork:", reason);
            revert(reason);
        }
        */

        vm.startBroadcast(privateKey);
        console.log("Started broadcasting transactions...");

        // Deploy Registry
        creationCode = type(Registry).creationCode;
        constructorArgs = abi.encode(dev0Address, dev0Address, address(0), address(0));
        console.log("Deploying Registry...");
        registry = Registry(deployContract("Registry V0.0", creationCode, constructorArgs, 0));
        console.log("Registry deployed at:", address(registry));

        // Deploy Price Router
        //creationCode = type(SequencerPriceRouter).creationCode;
        //constructorArgs = abi.encode(ARB_SEQUENCER_UPTIME_FEED, uint256(3_600), dev0Address, registry, WETH);
        creationCode = type(PriceRouter).creationCode;
        constructorArgs = abi.encode(dev0Address, WETH_USD_FEED, uint256(3_600), dev0Address, registry, WETH);
        console.log("Deploying Price Router...");
        priceRouter = PriceRouter(deployContract("PriceRouter", creationCode, constructorArgs, 0));
        console.log("Price Router deployed at:", address(priceRouter));
        
        // Update price router in registry.
        console.log("Updating price router in registry...");
        registry.setAddress(2, address(priceRouter));

        // Deploy ERC20Adaptor.
        creationCode = type(ERC20Adaptor).creationCode;
        constructorArgs = hex"";
        console.log("Deploying ERC20Adaptor...");
        erc20Adaptor = deployContract("ERC20Adaptor", creationCode, constructorArgs, 0);
        console.log("ERC20Adaptor deployed at:", erc20Adaptor);

        // Deploy SwapWithUniswapAdaptor.
        creationCode = type(SwapWithUniswapAdaptor).creationCode;
        constructorArgs = abi.encode(uniV2Router, uniV3Router);
        console.log("Deploying SwapWithUniswapAdaptor...");
        swapWithUniswapAdaptor = deployContract("SwapWithUniswapAdaptor", creationCode, constructorArgs, 0);
        console.log("SwapWithUniswapAdaptor deployed at:", swapWithUniswapAdaptor);

               // Deploy Aave V3 Adaptors.
               creationCode = type(AaveV3ATokenAdaptor).creationCode;
               constructorArgs = abi.encode(aaveV3Pool, aaveV3Oracle, AAVE_V3_MIN_HEALTH_FACTOR);
               console.log("Deploying AaveV3ATokenAdaptor...");
               aaveV3ATokenAdaptor = deployContract("AaveV3ATokenAdaptor", creationCode, constructorArgs, 0);
               console.log("AaveV3ATokenAdaptor deployed at:", aaveV3ATokenAdaptor);



               // Trust Adaptors in Registry.
               console.log("Trusting Adaptors in Registry...");
               registry.trustAdaptor(erc20Adaptor);
               registry.trustAdaptor(aaveV3ATokenAdaptor);


               // Add pricing.
               console.log("Adding pricing...");
               PriceRouter.ChainlinkDerivativeStorage memory stor;
               PriceRouter.AssetSettings memory settings;

               uint256 price = uint256(IChainlinkAggregator(WETHToUSD).latestAnswer()) * 1e8;
               priceRouter.addAsset(WETH, settings, price);

               price = uint256(IChainlinkAggregator(WSTETHToETH).latestAnswer());
               price = price.mulDivDown(uint256(IChainlinkAggregator(WETHToUSD).latestAnswer()), 1e18);
               priceRouter.addAsset(WSTETH, settings, price);

               price = uint256(IChainlinkAggregator(WBTCToUSD).latestAnswer());
               priceRouter.addAsset(WBTC, settings, price);

               price = uint256(IChainlinkAggregator(USDCToUSD).latestAnswer());
               priceRouter.addAsset(USDC, settings, price);

               price = uint256(IChainlinkAggregator(USDTToUSD).latestAnswer());
               priceRouter.addAsset(USDT, settings, price);

               price = uint256(IChainlinkAggregator(ARBToUSD).latestAnswer());
               priceRouter.addAsset(ARB, settings, price);

               price = uint256(IChainlinkAggregator(GMXToUSD).latestAnswer());
               priceRouter.addAsset(GMX, settings, price);

               price = uint256(IChainlinkAggregator(SOLToUSD).latestAnswer());
               priceRouter.addAsset(SOL, settings, price);

               price = uint256(IChainlinkAggregator(DAIToUSD).latestAnswer());
               priceRouter.addAsset(DAI, settings, price);

               // Load JSON settings for assets.
               console.log("Loading JSON settings for assets...");
               string memory json = vm.readFile("./script/Sepolia/production/assetSettings.json");
               settings = abi.decode(json.parseRaw("settings"), (PriceRouter.AssetSettings));
               console.log("Settings loaded.");

               // More assets can be added similarly with appropriate settings.

               // Trust pricing.
               console.log("Trusting pricing...");
               priceRouter.trustPrice(WETH, true);
               priceRouter.trustPrice(WSTETH, true);
               priceRouter.trustPrice(WBTC, true);
               priceRouter.trustPrice(USDC, true);
               priceRouter.trustPrice(USDT, true);
               priceRouter.trustPrice(ARB, true);
               priceRouter.trustPrice(GMX, true);
               priceRouter.trustPrice(SOL, true);
               priceRouter.trustPrice(DAI, true);

        console.log("Deployment process completed successfully.");
        vm.stopBroadcast();
    }

    function deployContract(string memory name, bytes memory creationCode, bytes memory constructorArgs, uint256 value) internal returns (address addr) {
        bytes memory code = abi.encodePacked(creationCode, constructorArgs);
        console.log("Creating contract:", name);

        assembly {
            addr := create(value, add(code, 0x20), mload(code))
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        console.log(name, "deployed at address:", addr);
        return addr;
    }
}
