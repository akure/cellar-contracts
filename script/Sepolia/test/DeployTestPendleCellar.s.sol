// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import {Deployer} from "src/Deployer.sol";
import {Registry} from "src/Registry.sol";
import {PriceRouter} from "src/modules/price-router/PriceRouter.sol";
import {ERC4626SharePriceOracle, ERC20} from "src/base/ERC4626SharePriceOracle.sol";
import {CellarWithMultiAssetDeposit, Cellar} from "src/base/permutations/CellarWithMultiAssetDeposit.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {PendleAdaptor, TokenInput, TokenOutput} from "src/modules/adaptors/Pendle/PendleAdaptor.sol";
import {PendleExtension} from "src/modules/price-router/Extensions/Pendle/PendleExtension.sol";
import {IChainlinkAggregator} from "src/interfaces/external/IChainlinkAggregator.sol";
import "forge-std/Script.sol";
import {ArbitrumAddresses} from "test/resources/Arbitrum/ArbitrumAddresses.sol";

/**
 * @dev Run
 *      `source .env && forge script script/Arbitrum/test/DeployTestPendleCellar.s.sol:DeployTestPendleCellarScript --evm-version london --rpc-url $ARBITRUM_RPC_URL --private-key $PRIVATE_KEY —optimize —optimizer-runs 200 --with-gas-price 100000000 --verify --etherscan-api-key $ARBISCAN_KEY --slow --broadcast`
 * @dev Optionally can change `--with-gas-price` to something more reasonable
 */
contract DeployTestPendleCellarScript is Script, ArbitrumAddresses {
    using Address for address;

    // Declare the Debug event
    event Debug(string message, uint256 value);
    event ErrorLog(string message);

    Deployer public deployer = Deployer(deployerAddress);
    Registry public registry = Registry(0x43BD96931A47FBABd50727F6982c796B3C9A974C);
    PriceRouter public priceRouter = PriceRouter(0x6aC423c11bb65B1bc7C5Cf292b22e0CBa125f98A);
    PendleExtension private pendleExtension;
    PendleAdaptor private pendleAdaptor;

    address public erc20Adaptor = 0xcaDe581bD66104B278A2F47a43B05a2db64E871f;
    address public zeroXAdaptor = 0x48B11b282964AF32AA26A5f83323271e02E7fAF0;
    address public oneInchAdaptor = 0xc64A77Aad4c9e1d78EaDe6Ad204Df751eCD30173;

    uint8 public constant CHAINLINK_DERIVATIVE = 1;
    uint8 public constant TWAP_DERIVATIVE = 2;
    uint8 public constant EXTENSION_DERIVATIVE = 3;

    uint32 public wethPosition = 1;
    uint32 public weethPosition = 6;
    uint32 public pendleLpPosition = 101;
    uint32 public pendleSyPosition = 102;
    uint32 public pendlePtPosition = 103;
    uint32 public pendleYtPosition = 104;

    function run() external {
        vm.startBroadcast();

        emit Debug("Starting Deployment", block.number);

        // Check all required addresses
        require(address(deployer) != address(0), "Deployer address is zero");
        require(address(registry) != address(0), "Registry address is zero");
        require(address(priceRouter) != address(0), "PriceRouter address is zero");

        // Instantiate the cellar
        CellarWithMultiAssetDeposit cellar = CellarWithMultiAssetDeposit(0xFCe8161bB272a3109498dddd6FdD488C77BCE580);

        emit Debug("Before Adding Position", 1);

        // Start by adding only the first position
        try cellar.addPosition(1, weethPosition, abi.encode(true), false) {
            emit Debug("Position 1 Added", weethPosition);
        } catch Error(string memory reason) {
            emit ErrorLog(reason);
            revert("Failed to add Position 1 with reason");
        } catch (bytes memory lowLevelData) {
            emit Debug("Failed to add Position 1", weethPosition);
            emit Debug(string(lowLevelData), 0);
            revert("Failed to add Position 1 with low-level data");
        }

        vm.stopBroadcast();
    }
}
