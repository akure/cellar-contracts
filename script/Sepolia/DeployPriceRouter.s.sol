// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import {Deployer} from "src/Deployer.sol";
import {Registry} from "src/Registry.sol";
import {PriceRouter} from "src/modules/price-router/PriceRouter.sol";
// import {SequencerPriceRouter} from "src/modules/price-router/permutations/SequencerPriceRouter.sol";
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
import {SepoliaAddresses} from "test/resources/Sepolia/SepoliaAddresses.sol";
import {ContractDeploymentNames} from "resources/ContractDeploymentNames.sol";

import {PositionIds} from "resources/PositionIds.sol";
import {Math} from "src/utils/Math.sol";

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "forge-std/console.sol";


/**
 *  source .env && forge script script/Sepolia/production/DeployPriceRouter.s.sol:DeployPriceRouterScript --evm-version london --with-gas-price 100000000 --slow --broadcast --etherscan-api-key $ARBISCAN_KEY --verify
 * @dev Optionally can change `--with-gas-price` to something more reasonable
 *  source .env && forge script script/Sepolia/DeployPriceRouter.s.sol:DeployPriceRouterScript --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast  --slow
 */
contract DeployPriceRouterScript is Script, SepoliaAddresses, ContractDeploymentNames, PositionIds {
    using Math for uint256;
    using stdJson for string;

    uint256 public privateKey;
    Deployer public deployer = Deployer(deployerAddress);
    Registry public registry;
    PriceRouter public priceRouter;

    uint8 public constant CHAINLINK_DERIVATIVE = 1;
    uint8 public constant TWAP_DERIVATIVE = 2;
    uint8 public constant EXTENSION_DERIVATIVE = 3;

    function setUp() external {
        privateKey = vm.envUint("PRIVATE_KEY");
        // TODO -
        // vm.createSelectFork("sepolia");
        // registry = Registry(deployer.getAddress(registryName));
        // registry = Registry(0x7eD42A7feF1C4203628E247aC73B8e99d33b6aBD);
    }

    function run() external {
        bytes memory creationCode;
        bytes memory constructorArgs;
        vm.startBroadcast(privateKey);

        // Deploy a new Registry
        creationCode = type(Registry).creationCode;
        constructorArgs = abi.encode(dev0Address, dev0Address, address(0), address(0));
        registry = Registry(deployContract(registryName, creationCode, constructorArgs, 0));
        console.log("Registry deployed at:", address(registry));
        console.log("Registry Owner is:", registry.owner());
        console.log("Registry nextId is:", registry.nextId());
        console.log("Registry at index 1 :", registry.getAddress(1));
        console.log("Registry at index 2 :", registry.getAddress(2));

        // Deploy Price Router
        // creationCode = type(PriceRouter).creationCode;
        // constructorArgs = abi.encode(ARB_SEQUENCER_UPTIME_FEED, uint256(3_600), dev0Address, registry, WETH);
        // priceRouter = PriceRouter(deployer.deployContract(priceRouterName, creationCode, constructorArgs, 0));
        
        // Deploy Price Router
        creationCode = type(PriceRouter).creationCode;
        console.log("Price Router creation code length:", creationCode.length);
        constructorArgs = abi.encode(dev0Address, registry, WETH);
        console.log("Price Router constructor arguments:");
        console.log("  newOwner:", dev0Address);
        console.log("  registry:", address(registry));
        console.log("  WETH:", address(WETH));
        priceRouter = PriceRouter(deployContract(priceRouterName, creationCode, constructorArgs, 0));
        console.log("Price Router deployed at:", address(priceRouter));

        // Update price router in registry.
        registry.setAddress(2, address(priceRouter));
        console.log("Price Router address updated in Registry with ID 2");
        // Add pricing.
        PriceRouter.ChainlinkDerivativeStorage memory stor;
        PriceRouter.AssetSettings memory settings;

        uint256 price = uint256(IChainlinkAggregator(WETH_USD_FEED).latestAnswer());
        console.log("Fetched price from Chainlink feed (WETH/USD):", price);
        settings = PriceRouter.AssetSettings(CHAINLINK_DERIVATIVE, WETH_USD_FEED);

        console.log("AssetSettings for WETH:");
        console.log("  derivative:", settings.derivative);
        console.log("  source:", settings.source);

        priceRouter.addAsset(WETH, settings, abi.encode(stor), price);
        console.log("Added WETH asset to PriceRouter");
        // price = priceRouter.getValue(WETH, price, USDC);
        // console.log("Added WETH asset from PriceRouter :", price);

        /*
        price = uint256(IChainlinkAggregator(USDC_USD_FEED).latestAnswer());
        settings = PriceRouter.AssetSettings(CHAINLINK_DERIVATIVE, USDC_USD_FEED);
        priceRouter.addAsset(USDC, settings, abi.encode(stor), price);

        price = uint256(IChainlinkAggregator(USDCe_USD_FEED).latestAnswer());
        settings = PriceRouter.AssetSettings(CHAINLINK_DERIVATIVE, USDCe_USD_FEED);
        priceRouter.addAsset(USDCe, settings, abi.encode(stor), price);

        price = uint256(IChainlinkAggregator(DAI_USD_FEED).latestAnswer());
        settings = PriceRouter.AssetSettings(CHAINLINK_DERIVATIVE, DAI_USD_FEED);
        priceRouter.addAsset(DAI, settings, abi.encode(stor), price);

        price = uint256(IChainlinkAggregator(USDT_USD_FEED).latestAnswer());
        settings = PriceRouter.AssetSettings(CHAINLINK_DERIVATIVE, USDT_USD_FEED);
        priceRouter.addAsset(USDT, settings, abi.encode(stor), price);

        price = uint256(IChainlinkAggregator(LUSD_USD_FEED).latestAnswer());
        settings = PriceRouter.AssetSettings(CHAINLINK_DERIVATIVE, LUSD_USD_FEED);
        priceRouter.addAsset(LUSD, settings, abi.encode(stor), price);

        price = uint256(IChainlinkAggregator(FRAX_USD_FEED).latestAnswer());
        settings = PriceRouter.AssetSettings(CHAINLINK_DERIVATIVE, FRAX_USD_FEED);
        priceRouter.addAsset(FRAX, settings, abi.encode(stor), price);


        stor.inETH = true;

        price = uint256(IChainlinkAggregator(WSTETH_EXCHANGE_RATE_FEED).latestAnswer());
        price = priceRouter.getValue(WETH, price, USDC);
        price = price.changeDecimals(6, 8);
        settings = PriceRouter.AssetSettings(CHAINLINK_DERIVATIVE, WSTETH_EXCHANGE_RATE_FEED);
        priceRouter.addAsset(WSTETH, settings, abi.encode(stor), price);

        price = uint256(IChainlinkAggregator(RETH_EXCHANGE_RATE_FEED).latestAnswer());
        price = priceRouter.getValue(WETH, price, USDC);
        price = price.changeDecimals(6, 8);
        settings = PriceRouter.AssetSettings(CHAINLINK_DERIVATIVE, RETH_EXCHANGE_RATE_FEED);
        priceRouter.addAsset(rETH, settings, abi.encode(stor), price);

        priceRouter.transferOwnership(multisig);
         */
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
