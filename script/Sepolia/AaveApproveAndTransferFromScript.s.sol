// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

// Self Approval and Transfer to Other contract.
// source .env && forge script script/Sepolia/AaveApproveAndTransferFromScript.s.sol:AaveApproveAndTransferFromScript --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
contract AaveApproveAndTransferFromScript is Script {
    // Aave V3 Sepolia addresses
    address public aaveAdaptorAddress = 0x91542358C085f4fbce50194B3Ddb293E12db0F7a; // Previously deployed AaveV3ATokenAdaptor address
    ERC20 public testUSDC = ERC20(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238); // USDC on Sepolia testnet

    function run() public {
        console.log("Running AaveApproveAndTransferFromScript:");

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(privateKey);

        // Start broadcasting transactions to the network
        vm.startBroadcast(privateKey);

        // Amount to approve and transfer
        uint256 approvalAmount = 500; // 0.0005 USDC
        uint256 transferAmount = 300; // 0.0003 USDC

        // Step 1: Approve the adaptor contract to spend USDC on behalf of the sender
        console.log("Approving the self (sender) to spend USDC...");
        bool approveSuccess = testUSDC.approve(sender, approvalAmount);
        require(approveSuccess, "Approval failed");
        console.log("Approval successful: adaptor approved to spend", approvalAmount, "USDC");

        // Check allowance after approval
        uint256 allowance = testUSDC.allowance(sender, sender);
        console.log("self allowance from sender:", allowance);


        // Check balances after transfer
        uint256 balanceBeforeTransfer = testUSDC.balanceOf(sender);
        console.log("Caller USDC balance after transfer:", balanceBeforeTransfer);

        uint256 adaptorBalanceBeforeTransfer = testUSDC.balanceOf(aaveAdaptorAddress);
        console.log("Adaptor USDC balance before transfer:", adaptorBalanceBeforeTransfer);

        // Step 2: Use transferFrom to transfer USDC from sender to the adaptor contract
        console.log("Using transferFrom to transfer USDC from sender to the adaptor...");
        bool transferFromSuccess = testUSDC.transferFrom(sender, aaveAdaptorAddress, transferAmount);
        require(transferFromSuccess, "TransferFrom failed");
        console.log("TransferFrom successful:", transferAmount, "USDC transferred to adaptor");

        // Check balances after transfer
        uint256 balanceAfterTransfer = testUSDC.balanceOf(sender);
        console.log("Caller USDC balance after transfer:", balanceAfterTransfer);

        uint256 adaptorBalanceAfterTransfer = testUSDC.balanceOf(aaveAdaptorAddress);
        console.log("Adaptor USDC balance after transfer:", adaptorBalanceAfterTransfer);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}


/*
source .env && forge script script/Sepolia/AaveApproveAndTransferFromScript.s.sol:AaveApproveAndTransferFromScript --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
[⠢] Compiling...
[⠊] Compiling 1 files with Solc 0.8.21
[⠒] Solc 0.8.21 finished in 782.67ms
Compiler run successful!
Traces:
  [81582] AaveApproveAndTransferFromScript::run()
    ├─ [0] console::log("Running AaveApproveAndTransferFromScript:") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [0] console::log("Approving the self (sender) to spend USDC...") [staticcall]
    │   └─ ← [Stop]
    ├─ [33841] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::approve(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 500)
    │   ├─ [26673] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::approve(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 500) [delegatecall]
    │   │   ├─ emit Approval(owner: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, spender: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, amount: 500)
    │   │   └─ ← [Return] true
    │   └─ ← [Return] true
    ├─ [0] console::log("Approval successful: adaptor approved to spend", 500, "USDC") [staticcall]
    │   └─ ← [Stop]
    ├─ [1359] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::allowance(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [staticcall]
    │   ├─ [659] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::allowance(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [delegatecall]
    │   │   └─ ← [Return] 500
    │   └─ ← [Return] 500
    ├─ [0] console::log("self allowance from sender:", 500) [staticcall]
    │   └─ ← [Stop]
    ├─ [3250] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [staticcall]
    │   ├─ [2553] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [delegatecall]
    │   │   └─ ← [Return] 9999000 [9.999e6]
    │   └─ ← [Return] 9999000 [9.999e6]
    ├─ [0] console::log("Caller USDC balance after transfer:", 9999000 [9.999e6]) [staticcall]
    │   └─ ← [Stop]
    ├─ [3250] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::balanceOf(0x91542358C085f4fbce50194B3Ddb293E12db0F7a) [staticcall]
    │   ├─ [2553] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::balanceOf(0x91542358C085f4fbce50194B3Ddb293E12db0F7a) [delegatecall]
    │   │   └─ ← [Return] 1000
    │   └─ ← [Return] 1000
    ├─ [0] console::log("Adaptor USDC balance before transfer:", 1000) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Using transferFrom to transfer USDC from sender to the adaptor...") [staticcall]
    │   └─ ← [Stop]
    ├─ [12028] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::transferFrom(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x91542358C085f4fbce50194B3Ddb293E12db0F7a, 300)
    │   ├─ [11354] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::transferFrom(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x91542358C085f4fbce50194B3Ddb293E12db0F7a, 300) [delegatecall]
    │   │   ├─ emit Transfer(from: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, to: 0x91542358C085f4fbce50194B3Ddb293E12db0F7a, amount: 300)
    │   │   └─ ← [Return] true
    │   └─ ← [Return] true
    ├─ [0] console::log("TransferFrom successful:", 300, "USDC transferred to adaptor") [staticcall]
    │   └─ ← [Stop]
    ├─ [1250] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [staticcall]
    │   ├─ [553] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [delegatecall]
    │   │   └─ ← [Return] 9998700 [9.998e6]
    │   └─ ← [Return] 9998700 [9.998e6]
    ├─ [0] console::log("Caller USDC balance after transfer:", 9998700 [9.998e6]) [staticcall]
    │   └─ ← [Stop]
    ├─ [1250] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::balanceOf(0x91542358C085f4fbce50194B3Ddb293E12db0F7a) [staticcall]
    │   ├─ [553] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::balanceOf(0x91542358C085f4fbce50194B3Ddb293E12db0F7a) [delegatecall]
    │   │   └─ ← [Return] 1300
    │   └─ ← [Return] 1300
    ├─ [0] console::log("Adaptor USDC balance after transfer:", 1300) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Stop]


Script ran successfully.

== Logs ==
  Running AaveApproveAndTransferFromScript:
  Approving the self (sender) to spend USDC...
  Approval successful: adaptor approved to spend 500 USDC
  self allowance from sender: 500
  Caller USDC balance after transfer: 9999000
  Adaptor USDC balance before transfer: 1000
  Using transferFrom to transfer USDC from sender to the adaptor...
  TransferFrom successful: 300 USDC transferred to adaptor
  Caller USDC balance after transfer: 9998700
  Adaptor USDC balance after transfer: 1300

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [33841] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::approve(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 500)
    ├─ [26673] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::approve(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 500) [delegatecall]
    │   ├─ emit Approval(owner: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, spender: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, amount: 500)
    │   └─ ← [Return] true
    └─ ← [Return] true

  [29328] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::transferFrom(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x91542358C085f4fbce50194B3Ddb293E12db0F7a, 300)
    ├─ [22154] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::transferFrom(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x91542358C085f4fbce50194B3Ddb293E12db0F7a, 300) [delegatecall]
    │   ├─ emit Transfer(from: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, to: 0x91542358C085f4fbce50194B3Ddb293E12db0F7a, amount: 300)
    │   └─ ← [Return] true
    └─ ← [Return] true


==========================

Chain 11155111

Estimated gas price: 14.586620714 gwei

Estimated total gas used for script: 151888

Estimated amount required: 0.002215532647008032 ETH

==========================

##### sepolia
✅  [Success]Hash: 0xa58aa94f363740bfdd3745be347ead37ad4cfc4467a4111f3fac52e73abaa7f2
Block: 6578774
Paid: 0.0004066550157128 ETH (51280 gas * 7.93009001 gwei)


##### sepolia
✅  [Success]Hash: 0x040ecca19190ff8e828ad7400eb62f2901f3e1c5f640a6bd6daa4d265b3519f5
Block: 6578774
Paid: 0.00043952523880425 ETH (55425 gas * 7.93009001 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.00084618025451705 ETH (106705 gas * avg 7.93009001 gwei)


==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Transactions saved to: /home/ak/somm/cellar-contracts/broadcast/AaveApproveAndTransferFromScript.s.sol/11155111/run-latest.json

Sensitive values saved to: /home/ak/somm/cellar-contracts/cache/AaveApproveAndTransferFromScript.s.sol/11155111/run-latest.json

*/