// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {AaveV3ATokenAdaptor} from "src/modules/adaptors/Aave/V3/AaveV3ATokenAdaptor.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract AaveBalanceTransferScript is Script {
    // Aave V3 Sepolia addresses
    address public aaveAdaptorAddress = 0x91542358C085f4fbce50194B3Ddb293E12db0F7a; // Previously deployed AaveV3ATokenAdaptor address
    ERC20 public testUSDC = ERC20(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238); // USDC on Sepolia testnet

    function run() public {
        console.log("Running AaveBalanceCheckScript:");

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(privateKey);

        // Start broadcasting transactions to the network
        vm.startBroadcast(privateKey);

        console.log("Starting checkBalance:");
        console.log("Address of caller :", address(sender));
        console.log("Address of this contract:", address(this));
        console.log("Address of adapter contract:", address(aaveAdaptorAddress));
        console.log("Address of testUSDC:", address(testUSDC));

        // Check the caller's balance before the transfer
        uint256 balanceBeforeTransfer = testUSDC.balanceOf(sender);
        console.log("Caller USDC balance before transfer:", balanceBeforeTransfer);

        // Check the adaptor's balance before the transfer
        uint256 adaptorBalanceBeforeTransfer = testUSDC.balanceOf(aaveAdaptorAddress);
        console.log("aaveAdaptorAddress USDC balance before transfer:", adaptorBalanceBeforeTransfer);

        // Define the amount of USDC to transfer (e.g., 0.001 USDC = 1000 units)
        uint256 transferAmount = 1000;

        // Transfer USDC from the caller to the Aave adaptor contract
        console.log("Transferring USDC from caller to the aaveAdaptorAddress...");
        bool success = testUSDC.transfer(aaveAdaptorAddress, transferAmount);
        require(success, "Transfer failed");
        console.log("Transfer successful:", transferAmount, "USDC transferred to aaveAdaptorAddress.");

        // Check the caller's balance after the transfer
        uint256 balanceAfterTransfer = testUSDC.balanceOf(sender);
        console.log("Caller USDC balance after transfer:", balanceAfterTransfer);

        // Check the adaptor's balance after the transfer
        uint256 adaptorBalanceAfterTransfer = testUSDC.balanceOf(aaveAdaptorAddress);
        console.log("aaveAdaptorAddress USDC balance after transfer:", adaptorBalanceAfterTransfer);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}

/*
 source .env && forge script script/Sepolia/AaveBalanceTransferScript.s.sol:AaveBalanceTransferScript --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
[⠢] Compiling...
[⠔] Compiling 1 files with Solc 0.8.21
[⠒] Solc 0.8.21 finished in 3.21s
Compiler run successful!
Traces:
  [70963] AaveBalanceTransferScript::run()
    ├─ [0] console::log("Running AaveBalanceCheckScript:") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [0] console::log("Starting checkBalance:") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Address of caller :", 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Address of this contract:", AaveBalanceTransferScript: [0x5b73C5498c1E3b4dbA84de0F1833c4a029d90519]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Address of adapter contract:", 0x91542358C085f4fbce50194B3Ddb293E12db0F7a) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Address of testUSDC:", 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238) [staticcall]
    │   └─ ← [Stop]
    ├─ [9750] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [staticcall]
    │   ├─ [2553] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [delegatecall]
    │   │   └─ ← [Return] 10000000 [1e7]
    │   └─ ← [Return] 10000000 [1e7]
    ├─ [0] console::log("Caller USDC balance before transfer:", 10000000 [1e7]) [staticcall]
    │   └─ ← [Stop]
    ├─ [3250] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::balanceOf(0x91542358C085f4fbce50194B3Ddb293E12db0F7a) [staticcall]
    │   ├─ [2553] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::balanceOf(0x91542358C085f4fbce50194B3Ddb293E12db0F7a) [delegatecall]
    │   │   └─ ← [Return] 0
    │   └─ ← [Return] 0
    ├─ [0] console::log("aaveAdaptorAddress USDC balance before transfer:", 0) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Transferring USDC from caller to the aaveAdaptorAddress...") [staticcall]
    │   └─ ← [Stop]
    ├─ [30063] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::transfer(0x91542358C085f4fbce50194B3Ddb293E12db0F7a, 1000)
    │   ├─ [29363] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::transfer(0x91542358C085f4fbce50194B3Ddb293E12db0F7a, 1000) [delegatecall]
    │   │   ├─ emit Transfer(from: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, to: 0x91542358C085f4fbce50194B3Ddb293E12db0F7a, amount: 1000)
    │   │   └─ ← [Return] true
    │   └─ ← [Return] true
    ├─ [0] console::log("Transfer successful:", 1000, "USDC transferred to aaveAdaptorAddress.") [staticcall]
    │   └─ ← [Stop]
    ├─ [1250] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [staticcall]
    │   ├─ [553] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [delegatecall]
    │   │   └─ ← [Return] 9999000 [9.999e6]
    │   └─ ← [Return] 9999000 [9.999e6]
    ├─ [0] console::log("Caller USDC balance after transfer:", 9999000 [9.999e6]) [staticcall]
    │   └─ ← [Stop]
    ├─ [1250] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::balanceOf(0x91542358C085f4fbce50194B3Ddb293E12db0F7a) [staticcall]
    │   ├─ [553] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::balanceOf(0x91542358C085f4fbce50194B3Ddb293E12db0F7a) [delegatecall]
    │   │   └─ ← [Return] 1000
    │   └─ ← [Return] 1000
    ├─ [0] console::log("aaveAdaptorAddress USDC balance after transfer:", 1000) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Stop]


Script ran successfully.

== Logs ==
  Running AaveBalanceCheckScript:
  Starting checkBalance:
  Address of caller : 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5
  Address of this contract: 0x5b73C5498c1E3b4dbA84de0F1833c4a029d90519
  Address of adapter contract: 0x91542358C085f4fbce50194B3Ddb293E12db0F7a
  Address of testUSDC: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
  Caller USDC balance before transfer: 10000000
  aaveAdaptorAddress USDC balance before transfer: 0
  Transferring USDC from caller to the aaveAdaptorAddress...
  Transfer successful: 1000 USDC transferred to aaveAdaptorAddress.
  Caller USDC balance after transfer: 9999000
  aaveAdaptorAddress USDC balance after transfer: 1000

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [40563] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::transfer(0x91542358C085f4fbce50194B3Ddb293E12db0F7a, 1000)
    ├─ [33363] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::transfer(0x91542358C085f4fbce50194B3Ddb293E12db0F7a, 1000) [delegatecall]
    │   ├─ emit Transfer(from: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, to: 0x91542358C085f4fbce50194B3Ddb293E12db0F7a, amount: 1000)
    │   └─ ← [Return] true
    └─ ← [Return] true


==========================

Chain 11155111

Estimated gas price: 8.740808152 gwei

Estimated total gas used for script: 90889

Estimated amount required: 0.000794443312127128 ETH

==========================

##### sepolia
✅  [Success]Hash: 0xf560a0c2ae23b3d5db1825af4adf213a86b97e5842e130ee14f422f536342965
Block: 6578636
Paid: 0.000269698103152108 ETH (62147 gas * 4.339680164 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.000269698103152108 ETH (62147 gas * avg 4.339680164 gwei)


==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Transactions saved to: /home/ak/somm/cellar-contracts/broadcast/AaveBalanceTransferScript.s.sol/11155111/run-latest.json

Sensitive values saved to: /home/ak/somm/cellar-contracts/cache/AaveBalanceTransferScript.s.sol/11155111/run-latest.json

*/