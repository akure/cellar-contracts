// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {PriceRouter} from "src/modules/price-router/PriceRouter.sol";
import {IChainlinkAggregator} from "src/interfaces/external/IChainlinkAggregator.sol";
import {SepoliaAddresses} from "test/resources/Sepolia/SepoliaAddresses.sol";
import {AaveV3ATokenAdaptor} from "src/modules/adaptors/Aave/V3/AaveV3ATokenAdaptor.sol";
import {ContractDeploymentNames} from "resources/ContractDeploymentNames.sol";

import {Registry} from "src/Registry.sol";
/**
* @notice An example of adding a price asset to the price router.
* command ->  source .env && forge script script/Sepolia/DeployAVVEV3Cellar.s.sol:DeployAVVEV3Cellar --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
*
**/
contract DeployAVVEV3Cellar is Script, SepoliaAddresses, ContractDeploymentNames {
    address public constant OWNER = 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5;
    address public constant REGISTRY = 0x484024aCbE5e5Bf5493bE14f43721481A2CF38DB;
    address public constant PRICE_ROUTER = 0x38Bc18f1e115d235E7D921eC41780b0c8244414F;

    uint256 public constant AAVE_V3_MIN_HEALTH_FACTOR = 1.01e18;

    uint8 public constant CHAINLINK_DERIVATIVE = 1;

    function run() external {
        bytes memory creationCode;
        bytes memory constructorArgs;

        vm.startBroadcast();

        // Initialize PriceRouter contract
        PriceRouter priceRouter = PriceRouter(PRICE_ROUTER);
        Registry registry = Registry(REGISTRY);
        console.log("Registry nextId is:", registry.nextId());
        console.log("Registry at index 1 :", registry.getAddress(1));
        console.log("Registry at index 2 :", registry.getAddress(2));
        console.log("Registry at index 3 :", registry.getAddress(3));

        // Deploy Aave V3 Adaptors.
        creationCode = type(AaveV3ATokenAdaptor).creationCode;
        constructorArgs = abi.encode(aaveV3Pool, aaveV3Oracle, AAVE_V3_MIN_HEALTH_FACTOR);
        console.log("Deploying AaveV3ATokenAdaptor...");
        AaveV3ATokenAdaptor aaveV3ATokenAdaptor = AaveV3ATokenAdaptor(deployContract(
            aaveV3ATokenAdaptorName,
            creationCode,
            constructorArgs,
            0));

        console.log("AaveV3ATokenAdaptor deployed at:", address(aaveV3ATokenAdaptor));

        // Trust Adaptors in Registry.
        console.log("Trusting Adaptors in Registry...");
        registry.trustAdaptor(address(aaveV3ATokenAdaptor));

        console.log("After Deployment, Registry nextId is:", registry.nextId());
        console.log("After Deployment, Registry at index 1 :", registry.getAddress(1));
        console.log("After Deployment, Registry at index 2 :", registry.getAddress(2));
        console.log("After Deployment, Registry at index 3 :", registry.getAddress(3));
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

/*
Expected output -

source .env && forge script script/Sepolia/DeployAVVEV3Cellar.s.sol:DeployAVVEV3Cellar --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
[⠆] Compiling...
[⠑] Compiling 2 files with Solc 0.8.21
[⠘] Solc 0.8.21 finished in 3.30s
Compiler run successful with warnings:
Warning (2072): Unused local variable.
  --> script/Sepolia/DeployAVVEV3Cellar.s.sol:34:9:
   |
34 |         PriceRouter priceRouter = PriceRouter(PRICE_ROUTER);
   |         ^^^^^^^^^^^^^^^^^^^^^^^

Script ran successfully.

== Logs ==
  Registry nextId is: 3
  Registry at index 1 : 0x0000000000000000000000000000000000000000
  Registry at index 2 : 0x38Bc18f1e115d235E7D921eC41780b0c8244414F
  Registry at index 3 : 0x0000000000000000000000000000000000000000
  Deploying AaveV3ATokenAdaptor...
  Creating contract: Aave V3 AToken Adaptor V0.0
  Aave V3 AToken Adaptor V0.0 deployed at address: 0x0D9Fbce03884cDD4Ad9DE463eBa884AAbCcad62c
  AaveV3ATokenAdaptor deployed at: 0x0D9Fbce03884cDD4Ad9DE463eBa884AAbCcad62c
  Trusting Adaptors in Registry...
  After Deployment, Registry nextId is: 3
  After Deployment, Registry at index 1 : 0x0000000000000000000000000000000000000000
  After Deployment, Registry at index 2 : 0x38Bc18f1e115d235E7D921eC41780b0c8244414F
  After Deployment, Registry at index 3 : 0x0000000000000000000000000000000000000000

## Setting up 1 EVM.

==========================

Chain 11155111

Estimated gas price: 0.034859276 gwei

Estimated total gas used for script: 2196975

Estimated amount required: 0.0000765849578901 ETH

==========================

##### sepolia
✅  [Success]Hash: 0x7ab33d9a6688d979474cbf32f225b02b4bfa43d1c4415fdd7f0e057819d12191
Contract Address: 0x0D9Fbce03884cDD4Ad9DE463eBa884AAbCcad62c
Block: 6525641
Paid: 0.000054326240227952 ETH (1606451 gas * 0.033817552 gwei)


##### sepolia
✅  [Success]Hash: 0x007beadc4d53675ea018f619b81c924f84c2d7c137b1e9b049ab9d38e531a8db
Block: 6525641
Paid: 0.000002510919418448 ETH (74249 gas * 0.033817552 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.0000568371596464 ETH (1680700 gas * avg 0.033817552 gwei)


==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Transactions saved to: /home/ak/somm/c2/cellar-contracts/broadcast/DeployAVVEV3Cellar.s.sol/11155111/run-latest.json

Sensitive values saved to: /home/ak/somm/c2/cellar-contracts/cache/DeployAVVEV3Cellar.s.sol/11155111/run-latest.json

*/
