// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

// source .env && forge script script/Sepolia/AaveApproveAndTransferFromScriptFail.s.sol:AaveApproveAndTransferFromScriptFail --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
contract AaveApproveAndTransferFromScriptFail is Script {
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
        console.log("Approving the adaptor to spend USDC...");
        bool approveSuccess = testUSDC.approve(aaveAdaptorAddress, approvalAmount);
        require(approveSuccess, "Approval failed");
        console.log("Approval successful: adaptor approved to spend", approvalAmount, "USDC");

        // Check allowance after approval
        uint256 allowance = testUSDC.allowance(sender, aaveAdaptorAddress);
        console.log("Adaptor's allowance from sender:", allowance);

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
[⠔] Compiling 120 files with Solc 0.8.21
[⠃] Solc 0.8.21 finished in 45.31s
Compiler run successful!
Traces:
  [585451] → new AaveApproveAndTransferFromScript@0x5b73C5498c1E3b4dbA84de0F1833c4a029d90519
    └─ ← [Return] 2703 bytes of code

  [45134] AaveApproveAndTransferFromScript::run()
    ├─ [0] console::log("Running AaveApproveAndTransferFromScript:") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [0] console::log("Approving the adaptor to spend USDC...") [staticcall]
    │   └─ ← [Stop]
    ├─ [16741] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::approve(0x91542358C085f4fbce50194B3Ddb293E12db0F7a, 500)
    │   ├─ [9573] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::approve(0x91542358C085f4fbce50194B3Ddb293E12db0F7a, 500) [delegatecall]
    │   │   ├─ emit Approval(owner: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, spender: 0x91542358C085f4fbce50194B3Ddb293E12db0F7a, amount: 500)
    │   │   └─ ← [Return] true
    │   └─ ← [Return] true
    ├─ [0] console::log("Approval successful: adaptor approved to spend", 500, "USDC") [staticcall]
    │   └─ ← [Stop]
    ├─ [1359] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::allowance(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x91542358C085f4fbce50194B3Ddb293E12db0F7a) [staticcall]
    │   ├─ [659] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::allowance(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x91542358C085f4fbce50194B3Ddb293E12db0F7a) [delegatecall]
    │   │   └─ ← [Return] 500
    │   └─ ← [Return] 500
    ├─ [0] console::log("Adaptor's allowance from sender:", 500) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Using transferFrom to transfer USDC from sender to the adaptor...") [staticcall]
    │   └─ ← [Stop]
    ├─ [8263] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::transferFrom(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x91542358C085f4fbce50194B3Ddb293E12db0F7a, 300)
    │   ├─ [7573] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::transferFrom(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x91542358C085f4fbce50194B3Ddb293E12db0F7a, 300) [delegatecall]
    │   │   └─ ← [Revert] revert: ERC20: transfer amount exceeds allowance
    │   └─ ← [Revert] revert: ERC20: transfer amount exceeds allowance
    └─ ← [Revert] revert: ERC20: transfer amount exceeds allowance



== Logs ==
  Running AaveApproveAndTransferFromScript:
  Approving the adaptor to spend USDC...
  Approval successful: adaptor approved to spend 500 USDC
  Adaptor's allowance from sender: 500
  Using transferFrom to transfer USDC from sender to the adaptor...
Error:
script failed: revert: ERC20: transfer amount exceeds allowance
*/
