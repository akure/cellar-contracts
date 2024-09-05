// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {AaveV3ATokenAdaptor} from "src/modules/adaptors/Aave/V3/AaveV3ATokenAdaptor.sol";
// source .env && forge script script/Sepolia/DeployAaveV3TokenAdaptor.s.sol:DeployAaveAdaptorScript --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
contract DeployAaveAdaptorScript is Script {
    AaveV3ATokenAdaptor public aaveAdaptor;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions to the network
        vm.startBroadcast(privateKey);

        console.log("Deploying AaveAdaptorScript...");

        // Set a realistic minimum health factor (e.g., 1.01)
        uint256 minHealthFactor = 1.01e18;

        // Deploy the AaveV3ATokenAdaptor contract
        aaveAdaptor = new AaveV3ATokenAdaptor(
            0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951,
            // 0x7Ee60D184C24Ef7AfC1Ec7Be59A0f448A0abd138, // Aave V3 Sepolia Pool
            0x2da88497588bf89281816106C7259e31AF45a663, // Aave V3 Sepolia Oracle
            minHealthFactor
        );


        console.log("Deployed AaveV3ATokenAdaptor at:", address(aaveAdaptor));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}

/*
source .env && forge script script/Sepolia/DeployAaveV3TokenAdaptor.s.sol:DeployAaveAdaptorScript --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
[⠒] Compiling...
[⠰] Compiling 1 files with Solc 0.8.21
[⠔] Solc 0.8.21 finished in 3.15s
Compiler run successful!
Traces:
  [1488318] DeployAaveAdaptorScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return] 
    ├─ [0] console::log("Deploying AaveAdaptorScript...") [staticcall]
    │   └─ ← [Stop] 
    ├─ [1441167] → new AaveV3ATokenAdaptor@0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928
    │   └─ ← [Return] 7194 bytes of code
    ├─ [0] console::log("Deployed AaveV3ATokenAdaptor at:", AaveV3ATokenAdaptor: [0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928]) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    └─ ← [Stop] 


Script ran successfully.

== Logs ==
  Deploying AaveAdaptorScript...
  Deployed AaveV3ATokenAdaptor at: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [1441167] → new AaveV3ATokenAdaptor@0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928
    └─ ← [Return] 7194 bytes of code


==========================

Chain 11155111

Estimated gas price: 66.339667882 gwei

Estimated total gas used for script: 2088370

Estimated amount required: 0.13854177221473234 ETH

==========================

##### sepolia
✅  [Success]Hash: 0xc11e848791c1eb4abf80c200336f3164d1526c63aecf97513794251876bcdef3
Contract Address: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928
Block: 6580939
Paid: 0.051390603910716826 ETH (1606439 gas * 31.990386134 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.051390603910716826 ETH (1606439 gas * avg 31.990386134 gwei)
                                                                                                                                                                              

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

*/
/*
source .env && forge script script/Sepolia/DeployAaveV3TokenAdaptor.s.sol:DeployAaveAdaptorScript --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
[⠢] Compiling...
[⠔] Compiling 1 files with Solc 0.8.21
[⠒] Solc 0.8.21 finished in 3.17s
Compiler run successful!
Traces:
  [1488318] DeployAaveAdaptorScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [0] console::log("Deploying AaveAdaptorScript...") [staticcall]
    │   └─ ← [Stop]
    ├─ [1441167] → new AaveV3ATokenAdaptor@0x91542358C085f4fbce50194B3Ddb293E12db0F7a
    │   └─ ← [Return] 7194 bytes of code
    ├─ [0] console::log("Deployed AaveV3ATokenAdaptor at:", AaveV3ATokenAdaptor: [0x91542358C085f4fbce50194B3Ddb293E12db0F7a]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Stop]


Script ran successfully.

== Logs ==
  Deploying AaveAdaptorScript...
  Deployed AaveV3ATokenAdaptor at: 0x91542358C085f4fbce50194B3Ddb293E12db0F7a

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [1441167] → new AaveV3ATokenAdaptor@0x91542358C085f4fbce50194B3Ddb293E12db0F7a
    └─ ← [Return] 7194 bytes of code


==========================

Chain 11155111

Estimated gas price: 15.890393266 gwei

Estimated total gas used for script: 2088386

Estimated amount required: 0.033185274831208676 ETH

==========================

##### sepolia
✅  [Success]Hash: 0x6c0911c370ec461ebf190a700d2acfd165732f14d949cb52e1f54bcc1c2ee2b2
Contract Address: 0x91542358C085f4fbce50194B3Ddb293E12db0F7a
Block: 6575368
Paid: 0.012881145223363032 ETH (1606451 gas * 8.018386632 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.012881145223363032 ETH (1606451 gas * avg 8.018386632 gwei)


==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Transactions saved to: /home/ak/somm/cellar-contracts/broadcast/DeployAaveV3TokenAdaptor.s.sol/11155111/run-latest.json

Sensitive values saved to: /home/ak/somm/cellar-contracts/cache/DeployAaveV3TokenAdaptor.s.sol/11155111/run-latest.json
*/
