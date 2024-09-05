// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {AaveV3ATokenAdaptor} from "src/modules/adaptors/Aave/V3/AaveV3ATokenAdaptor.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

// source .env && forge script script/Sepolia/AaveDepositWithSelfApprovalScript.s.sol:AaveDepositWithSelfApprovalScript --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
contract AaveDepositWithSelfApprovalScript is Script {
    // Aave V3 Sepolia addresses
    address public aaveAdaptorAddress = 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928;
    // address public aaveAdaptorAddress = 0x91542358C085f4fbce50194B3Ddb293E12db0F7a; // Previously deployed AaveV3ATokenAdaptor address
    // ERC20 public testUSDC = ERC20(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238); // USDC on Sepolia testnet
    ERC20 public testUSDC = ERC20(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8); // USDC on Sepolia testnet

    // 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8 -> this should be used for testnet USDC
    ERC20 public atestUSDC = ERC20(0x16dA4541aD1807f4443d92D26044C1147406EB80); // USDC on Sepolia testnet

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(privateKey);

        // Start broadcasting transactions to the network
        vm.startBroadcast(privateKey);
        console.log("Running AaveDepositWithSelfApprovalScript:");

        // Step 1: Approve the caller to spend its own USDC (self-approval)
        uint256 approvalAmount = 1000; // 0.001 USDC
        console.log("Self-approving USDC...");
        bool approveSuccess = testUSDC.approve(sender, approvalAmount);
        require(approveSuccess, "Self-approval failed");
        console.log("Self-approval successful for", approvalAmount, "USDC");

        // Check the self-allowance after approval
        uint256 allowance = testUSDC.allowance(sender, sender);
        console.log("Self-allowance from sender:", allowance);

        // Balance checks before transferFrom
        uint256 balanceBeforeTransferSender = testUSDC.balanceOf(sender);
        uint256 balanceBeforeTransferAdaptor = testUSDC.balanceOf(aaveAdaptorAddress);
        console.log("Caller USDC balance before transfer:", balanceBeforeTransferSender);
        console.log("Adaptor USDC balance before transfer:", balanceBeforeTransferAdaptor);

        // Step 2: Transfer USDC from sender to the adaptor contract using transferFrom
        uint256 transferAmount = 1000; // 0.001 USDC
        console.log("Transferring USDC from sender to the adaptor...");
        bool transferFromSuccess = testUSDC.transferFrom(sender, aaveAdaptorAddress, transferAmount);
        require(transferFromSuccess, "TransferFrom failed");
        console.log("TransferFrom successful:", transferAmount, "USDC transferred to adaptor");

        // Balance checks after transferFrom and before deposit
        uint256 balanceAfterTransferSender = testUSDC.balanceOf(sender);
        uint256 balanceAfterTransferAdaptor = testUSDC.balanceOf(aaveAdaptorAddress);
        console.log("Caller USDC balance after transfer:", balanceAfterTransferSender);
        console.log("Adaptor USDC balance after transfer:", balanceAfterTransferAdaptor);

        // Step 3: Deposit the USDC into Aave via the AaveV3ATokenAdaptor
        console.log("Depositing USDC into Aave via the AaveV3ATokenAdaptor...");
        AaveV3ATokenAdaptor aaveAdaptor = AaveV3ATokenAdaptor(aaveAdaptorAddress);
        bytes memory adaptorData = abi.encode(address(atestUSDC)); // Encode USDC address as part of the adaptor data

        // Call the deposit function on the adaptor
        // aaveAdaptor.deposit(transferAmount, adaptorData, "");
        aaveAdaptor.deposit(1, adaptorData, "");
        console.log("Deposit successful:", transferAmount, "USDC deposited via adaptor");

        // Balance checks after deposit
        uint256 balanceAfterDepositSender = testUSDC.balanceOf(sender);
        uint256 balanceAfterDepositAdaptor = testUSDC.balanceOf(aaveAdaptorAddress);
        console.log("Caller USDC balance after deposit:", balanceAfterDepositSender);
        console.log("Adaptor USDC balance after deposit:", balanceAfterDepositAdaptor);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}

/*

 source .env && forge script script/Sepolia/AaveDepositWithSelfApprovalScript.s.sol:AaveDepositWithSelfApprovalScript --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
[⠒] Compiling...
[⠰] Compiling 1 files with Solc 0.8.21
[⠔] Solc 0.8.21 finished in 3.18s
Compiler run successful!
Traces:
  [828401] → new AaveDepositWithSelfApprovalScript@0x5b73C5498c1E3b4dbA84de0F1833c4a029d90519
    └─ ← [Return] 3806 bytes of code

  [224609] AaveDepositWithSelfApprovalScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [0] console::log("Running AaveDepositWithSelfApprovalScript:") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Self-approving USDC...") [staticcall]
    │   └─ ← [Stop]
    ├─ [16741] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::approve(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 1000)
    │   ├─ [9573] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::approve(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 1000) [delegatecall]
    │   │   ├─ emit Approval(owner: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, spender: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, amount: 1000)
    │   │   └─ ← [Return] true
    │   └─ ← [Return] true
    ├─ [0] console::log("Self-approval successful for", 1000, "USDC") [staticcall]
    │   └─ ← [Stop]
    ├─ [1359] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::allowance(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [staticcall]
    │   ├─ [659] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::allowance(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [delegatecall]
    │   │   └─ ← [Return] 1000
    │   └─ ← [Return] 1000
    ├─ [0] console::log("Self-allowance from sender:", 1000) [staticcall]
    │   └─ ← [Stop]
    ├─ [3250] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [staticcall]
    │   ├─ [2553] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [delegatecall]
    │   │   └─ ← [Return] 9998700 [9.998e6]
    │   └─ ← [Return] 9998700 [9.998e6]
    ├─ [3250] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::balanceOf(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928) [staticcall]
    │   ├─ [2553] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::balanceOf(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928) [delegatecall]
    │   │   └─ ← [Return] 0
    │   └─ ← [Return] 0
    ├─ [0] console::log("Caller USDC balance before transfer:", 9998700 [9.998e6]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Adaptor USDC balance before transfer:", 0) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Transferring USDC from sender to the adaptor...") [staticcall]
    │   └─ ← [Stop]
    ├─ [29128] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::transferFrom(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 1000)
    │   ├─ [28454] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::transferFrom(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 1000) [delegatecall]
    │   │   ├─ emit Transfer(from: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, to: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, amount: 1000)
    │   │   └─ ← [Return] true
    │   └─ ← [Return] true
    ├─ [0] console::log("TransferFrom successful:", 1000, "USDC transferred to adaptor") [staticcall]
    │   └─ ← [Stop]
    ├─ [1250] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [staticcall]
    │   ├─ [553] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [delegatecall]
    │   │   └─ ← [Return] 9997700 [9.997e6]
    │   └─ ← [Return] 9997700 [9.997e6]
    ├─ [1250] 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238::balanceOf(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928) [staticcall]
    │   ├─ [553] 0xDa317C1d3E835dD5F1BE459006471aCAA1289068::balanceOf(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928) [delegatecall]
    │   │   └─ ← [Return] 1000
    │   └─ ← [Return] 1000
    ├─ [0] console::log("Caller USDC balance after transfer:", 9997700 [9.997e6]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Adaptor USDC balance after transfer:", 1000) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Depositing USDC into Aave via the AaveV3ATokenAdaptor...") [staticcall]
    │   └─ ← [Stop]
    ├─ [137353] 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928::deposit(1, 0x00000000000000000000000016da4541ad1807f4443d92d26044c1147406eb80, 0x)
    │   ├─ [7467] 0x16dA4541aD1807f4443d92D26044C1147406EB80::UNDERLYING_ASSET_ADDRESS() [staticcall]
    │   │   ├─ [2418] 0x48424f2779be0f03cDF6F02E17A591A9BF7AF89f::UNDERLYING_ASSET_ADDRESS() [delegatecall]
    │   │   │   └─ ← [Return] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8
    │   │   └─ ← [Return] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8
    │   ├─ [24619] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::approve(0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951, 1)
    │   │   ├─ emit Approval(owner: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, spender: 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951, amount: 1)
    │   │   └─ ← [Return] true
    │   ├─ [95365] 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951::supply(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, 1, 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0)
    │   │   ├─ [90285] 0x0562453c3DAFBB5e625483af58f4E6D668c44e19::supply(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, 1, 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0) [delegatecall]
    │   │   │   ├─ [86532] 0x77241299fFA12DF99Da6C3d9f195aa298955AEc6::1913f161(00000000000000000000000000000000000000000000000000000000000000340000000000000000000000000000000000000000000000000000000000000036c3c2b5c96d1956a3c91b89817deb58c26085065aae9bca5828bbeef95317794600000000000000000000000094a9d9ac8a22534e3faca9f4e7f2e2cf85d5e4c8000000000000000000000000000000000000000000000000000000000000000100000000000000000000000067c0c572d2aa85be05061e5c63ef6c1d896c19280000000000000000000000000000000000000000000000000000000000000000) [delegatecall]
    │   │   │   │   ├─ [7468] 0x36B5dE936eF1710E1d22EabE5231b28581a92ECc::scaledTotalSupply() [staticcall]
    │   │   │   │   │   ├─ [2419] 0x54bdE009156053108E73E2401aEA755e38f92098::scaledTotalSupply() [delegatecall]
    │   │   │   │   │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000109fcfa43426
    │   │   │   │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000109fcfa43426
    │   │   │   │   ├─ [11676] 0x42A218F7bd03c63c4835496506492A383EfcF726::getSupplyData() [staticcall]
    │   │   │   │   │   ├─ [6615] 0xd1CF2FBf4fb82045eE0B116eB107d29246E8DCe9::getSupplyData() [delegatecall]
    │   │   │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000000000000002f7064d1587000000000000000000000000000000000000000000000000000002f7bfa23f030000000000000000000000000000000000000000002e40348e4d5d16db8aae470000000000000000000000000000000000000000000000000000000066cd8654
    │   │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000000000000002f7064d1587000000000000000000000000000000000000000000000000000002f7bfa23f030000000000000000000000000000000000000000002e40348e4d5d16db8aae470000000000000000000000000000000000000000000000000000000066cd8654
    │   │   │   │   ├─ [2924] 0x16dA4541aD1807f4443d92D26044C1147406EB80::scaledTotalSupply() [staticcall]
    │   │   │   │   │   ├─ [2375] 0x48424f2779be0f03cDF6F02E17A591A9BF7AF89f::scaledTotalSupply() [delegatecall]
    │   │   │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000000000000014cbfd8bc5a4
    │   │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000000000000014cbfd8bc5a4
    │   │   │   │   ├─ [7176] 0x5CB1008969a2d5FAcE8eF32732e6A306d0D0EF2A::calculateInterestRates((0, 1, 0, 3263095258883 [3.263e12], 20096183397150 [2.009e13], 55913788641822711573294663 [5.591e25], 1000, 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, 0x16dA4541aD1807f4443d92D26044C1147406EB80)) [staticcall]
    │   │   │   │   │   ├─ [2605] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::balanceOf(0x16dA4541aD1807f4443d92D26044C1147406EB80) [staticcall]
    │   │   │   │   │   │   └─ ← [Return] 1390770788175 [1.39e12]
    │   │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000bc8cf22c1c6bceba4b45a200000000000000000000000000000000000000000106ea1c3541c06a3c891e10000000000000000000000000000000000000000000fa81bc9423be7dcd891e10
    │   │   │   │   ├─ emit ReserveDataUpdated(reserve: 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, liquidityRate: 227943652685751845535827362 [2.279e26], stableBorrowRate: 317844118842418324631526928 [3.178e26], variableBorrowRate: 302844118842418324631526928 [3.028e26], liquidityIndex: 1076426613819183327860252376 [1.076e27], variableBorrowIndex: 1099439614722216230165407725 [1.099e27])
    │   │   │   │   ├─ [3282] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::transferFrom(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0x16dA4541aD1807f4443d92D26044C1147406EB80, 1)
    │   │   │   │   │   └─ ← [Revert] revert: ERC20: transfer amount exceeds balance
    │   │   │   │   └─ ← [Revert] revert: ERC20: transfer amount exceeds balance
    │   │   │   └─ ← [Revert] revert: ERC20: transfer amount exceeds balance
    │   │   └─ ← [Revert] revert: ERC20: transfer amount exceeds balance
    │   └─ ← [Revert] revert: ERC20: transfer amount exceeds balance
    └─ ← [Revert] revert: ERC20: transfer amount exceeds balance



== Logs ==
  Running AaveDepositWithSelfApprovalScript:
  Self-approving USDC...
  Self-approval successful for 1000 USDC
  Self-allowance from sender: 1000
  Caller USDC balance before transfer: 9998700
  Adaptor USDC balance before transfer: 0
  Transferring USDC from sender to the adaptor...
  TransferFrom successful: 1000 USDC transferred to adaptor
  Caller USDC balance after transfer: 9997700
  Adaptor USDC balance after transfer: 1000
  Depositing USDC into Aave via the AaveV3ATokenAdaptor...
Error:
script failed: revert: ERC20: transfer amount exceeds balance
ak@ak-pad:~/somm/cellar-contracts$ vim .env
ak@ak-pad:~/somm/cellar-contracts$ source .env && forge script script/Sepolia/AaveDepositWithSelfApprovalScript.s.sol:AaveDepositWithSelfApprovalScript --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
[⠆] Compiling...
[⠆] Compiling 1 files with Solc 0.8.21
[⠰] Solc 0.8.21 finished in 3.95s
Compiler run successful!
Traces:
  [310944] AaveDepositWithSelfApprovalScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [0] console::log("Running AaveDepositWithSelfApprovalScript:") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Self-approving USDC...") [staticcall]
    │   └─ ← [Stop]
    ├─ [24619] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::approve(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 1000)
    │   ├─ emit Approval(owner: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, spender: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, amount: 1000)
    │   └─ ← [Return] true
    ├─ [0] console::log("Self-approval successful for", 1000, "USDC") [staticcall]
    │   └─ ← [Stop]
    ├─ [756] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::allowance(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [staticcall]
    │   └─ ← [Return] 1000
    ├─ [0] console::log("Self-allowance from sender:", 1000) [staticcall]
    │   └─ ← [Stop]
    ├─ [2605] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [staticcall]
    │   └─ ← [Return] 10000000000 [1e10]
    ├─ [2605] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::balanceOf(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928) [staticcall]
    │   └─ ← [Return] 0
    ├─ [0] console::log("Caller USDC balance before transfer:", 10000000000 [1e10]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Adaptor USDC balance before transfer:", 0) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Transferring USDC from sender to the adaptor...") [staticcall]
    │   └─ ← [Stop]
    ├─ [28674] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::transferFrom(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 1000)
    │   ├─ emit Transfer(from: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, to: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, amount: 1000)
    │   ├─ emit Approval(owner: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, spender: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, amount: 0)
    │   └─ ← [Return] true
    ├─ [0] console::log("TransferFrom successful:", 1000, "USDC transferred to adaptor") [staticcall]
    │   └─ ← [Stop]
    ├─ [605] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [staticcall]
    │   └─ ← [Return] 9999999000 [9.999e9]
    ├─ [605] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::balanceOf(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928) [staticcall]
    │   └─ ← [Return] 1000
    ├─ [0] console::log("Caller USDC balance after transfer:", 9999999000 [9.999e9]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Adaptor USDC balance after transfer:", 1000) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Depositing USDC into Aave via the AaveV3ATokenAdaptor...") [staticcall]
    │   └─ ← [Stop]
    ├─ [214227] 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928::deposit(1, 0x00000000000000000000000016da4541ad1807f4443d92d26044c1147406eb80, 0x)
    │   ├─ [7467] 0x16dA4541aD1807f4443d92D26044C1147406EB80::UNDERLYING_ASSET_ADDRESS() [staticcall]
    │   │   ├─ [2418] 0x48424f2779be0f03cDF6F02E17A591A9BF7AF89f::UNDERLYING_ASSET_ADDRESS() [delegatecall]
    │   │   │   └─ ← [Return] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8
    │   │   └─ ← [Return] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8
    │   ├─ [24619] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::approve(0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951, 1)
    │   │   ├─ emit Approval(owner: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, spender: 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951, amount: 1)
    │   │   └─ ← [Return] true
    │   ├─ [173544] 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951::supply(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, 1, 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0)
    │   │   ├─ [168480] 0x0562453c3DAFBB5e625483af58f4E6D668c44e19::supply(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, 1, 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0) [delegatecall]
    │   │   │   ├─ [164732] 0x77241299fFA12DF99Da6C3d9f195aa298955AEc6::1913f161(00000000000000000000000000000000000000000000000000000000000000340000000000000000000000000000000000000000000000000000000000000036c3c2b5c96d1956a3c91b89817deb58c26085065aae9bca5828bbeef95317794600000000000000000000000094a9d9ac8a22534e3faca9f4e7f2e2cf85d5e4c8000000000000000000000000000000000000000000000000000000000000000100000000000000000000000067c0c572d2aa85be05061e5c63ef6c1d896c19280000000000000000000000000000000000000000000000000000000000000000) [delegatecall]
    │   │   │   │   ├─ [7468] 0x36B5dE936eF1710E1d22EabE5231b28581a92ECc::scaledTotalSupply() [staticcall]
    │   │   │   │   │   ├─ [2419] 0x54bdE009156053108E73E2401aEA755e38f92098::scaledTotalSupply() [delegatecall]
    │   │   │   │   │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000109fcfa43426
    │   │   │   │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000109fcfa43426
    │   │   │   │   ├─ [11676] 0x42A218F7bd03c63c4835496506492A383EfcF726::getSupplyData() [staticcall]
    │   │   │   │   │   ├─ [6615] 0xd1CF2FBf4fb82045eE0B116eB107d29246E8DCe9::getSupplyData() [delegatecall]
    │   │   │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000000000000002f7064d1587000000000000000000000000000000000000000000000000000002f7c03acb4d0000000000000000000000000000000000000000002e40348e4d5d16db8aae470000000000000000000000000000000000000000000000000000000066cd8654
    │   │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000000000000002f7064d1587000000000000000000000000000000000000000000000000000002f7c03acb4d0000000000000000000000000000000000000000002e40348e4d5d16db8aae470000000000000000000000000000000000000000000000000000000066cd8654
    │   │   │   │   ├─ [2924] 0x16dA4541aD1807f4443d92D26044C1147406EB80::scaledTotalSupply() [staticcall]
    │   │   │   │   │   ├─ [2375] 0x48424f2779be0f03cDF6F02E17A591A9BF7AF89f::scaledTotalSupply() [delegatecall]
    │   │   │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000000000000014cbfd8bc5a4
    │   │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000000000000014cbfd8bc5a4
    │   │   │   │   ├─ [7176] 0x5CB1008969a2d5FAcE8eF32732e6A306d0D0EF2A::calculateInterestRates((0, 1, 0, 3263105256269 [3.263e12], 20096516879001 [2.009e13], 55913788641822711573294663 [5.591e25], 1000, 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, 0x16dA4541aD1807f4443d92D26044C1147406EB80)) [staticcall]
    │   │   │   │   │   ├─ [2605] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::balanceOf(0x16dA4541aD1807f4443d92D26044C1147406EB80) [staticcall]
    │   │   │   │   │   │   └─ ← [Return] 1390770788175 [1.39e12]
    │   │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000bc8dc83a9a360731539e2a00000000000000000000000000000000000000000106eb19dad73e48eb31c3f2000000000000000000000000000000000000000000fa82ba39b93c5c7c31c3f2
    │   │   │   │   ├─ emit ReserveDataUpdated(reserve: 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, liquidityRate: 227947601333196651863711274 [2.279e26], stableBorrowRate: 317848797800250156302582770 [3.178e26], variableBorrowRate: 302848797800250156302582770 [3.028e26], liquidityIndex: 1076440058380423472113749084 [1.076e27], variableBorrowIndex: 1099457859139629056708188904 [1.099e27])
    │   │   │   │   ├─ [8774] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::transferFrom(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0x16dA4541aD1807f4443d92D26044C1147406EB80, 1)
    │   │   │   │   │   ├─ emit Transfer(from: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, to: 0x16dA4541aD1807f4443d92D26044C1147406EB80, amount: 1)
    │   │   │   │   │   ├─ emit Approval(owner: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, spender: 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951, amount: 0)
    │   │   │   │   │   └─ ← [Return] true
    │   │   │   │   ├─ [45082] 0x16dA4541aD1807f4443d92D26044C1147406EB80::mint(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 1, 1076440058380423472113749084 [1.076e27])
    │   │   │   │   │   ├─ [44515] 0x48424f2779be0f03cDF6F02E17A591A9BF7AF89f::mint(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 1, 1076440058380423472113749084 [1.076e27]) [delegatecall]
    │   │   │   │   │   │   ├─ [7701] 0x4DA5c4da71C5a167171cC839487536d86e083483::handleAction(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 22866364712356 [2.286e13], 0)
    │   │   │   │   │   │   │   ├─ [2675] 0xDe7562059fE64B3D088a26a3F8B60e77dCb81ebE::handleAction(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 22866364712356 [2.286e13], 0) [delegatecall]
    │   │   │   │   │   │   │   │   └─ ← [Stop]
    │   │   │   │   │   │   │   └─ ← [Return]
    │   │   │   │   │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, amount: 1)
    │   │   │   │   │   │   ├─ emit Mint(param0: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, param1: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, param2: 1, param3: 0, param4: 1076440058380423472113749084 [1.076e27])
    │   │   │   │   │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000000000000001
    │   │   │   │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000000000000001
    │   │   │   │   ├─ emit ReserveUsedAsCollateralEnabled(reserve: 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, user: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928)
    │   │   │   │   ├─ emit Supply(reserve: 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, user: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, onBehalfOf: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, amount: 1, referralCode: 0)
    │   │   │   │   └─ ← [Stop]
    │   │   │   └─ ← [Stop]
    │   │   └─ ← [Return]
    │   ├─ [756] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::allowance(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951) [staticcall]
    │   │   └─ ← [Return] 0
    │   └─ ← [Stop]
    ├─ [0] console::log("Deposit successful:", 1000, "USDC deposited via adaptor") [staticcall]
    │   └─ ← [Stop]
    ├─ [605] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::balanceOf(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5) [staticcall]
    │   └─ ← [Return] 9999999000 [9.999e9]
    ├─ [605] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::balanceOf(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928) [staticcall]
    │   └─ ← [Return] 999
    ├─ [0] console::log("Caller USDC balance after deposit:", 9999999000 [9.999e9]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log("Adaptor USDC balance after deposit:", 999) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Stop]


Script ran successfully.

== Logs ==
  Running AaveDepositWithSelfApprovalScript:
  Self-approving USDC...
  Self-approval successful for 1000 USDC
  Self-allowance from sender: 1000
  Caller USDC balance before transfer: 10000000000
  Adaptor USDC balance before transfer: 0
  Transferring USDC from sender to the adaptor...
  TransferFrom successful: 1000 USDC transferred to adaptor
  Caller USDC balance after transfer: 9999999000
  Adaptor USDC balance after transfer: 1000
  Depositing USDC into Aave via the AaveV3ATokenAdaptor...
  Deposit successful: 1000 USDC deposited via adaptor
  Caller USDC balance after deposit: 9999999000
  Adaptor USDC balance after deposit: 999

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [24619] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::approve(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 1000)
    ├─ emit Approval(owner: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, spender: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, amount: 1000)
    └─ ← [Return] true

  [37474] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::transferFrom(0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 1000)
    ├─ emit Transfer(from: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, to: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, amount: 1000)
    ├─ emit Approval(owner: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, spender: 0x35c5cA6CD3656E5f8362AE25A6b5973A6070bEf5, amount: 0)
    └─ ← [Return] true

  [221527] 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928::deposit(1, 0x00000000000000000000000016da4541ad1807f4443d92d26044c1147406eb80, 0x)
    ├─ [7467] 0x16dA4541aD1807f4443d92D26044C1147406EB80::UNDERLYING_ASSET_ADDRESS() [staticcall]
    │   ├─ [2418] 0x48424f2779be0f03cDF6F02E17A591A9BF7AF89f::UNDERLYING_ASSET_ADDRESS() [delegatecall]
    │   │   └─ ← [Return] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8
    │   └─ ← [Return] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8
    ├─ [24619] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::approve(0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951, 1)
    │   ├─ emit Approval(owner: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, spender: 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951, amount: 1)
    │   └─ ← [Return] true
    ├─ [178344] 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951::supply(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, 1, 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0)
    │   ├─ [173280] 0x0562453c3DAFBB5e625483af58f4E6D668c44e19::supply(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, 1, 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0) [delegatecall]
    │   │   ├─ [169532] 0x77241299fFA12DF99Da6C3d9f195aa298955AEc6::1913f161(00000000000000000000000000000000000000000000000000000000000000340000000000000000000000000000000000000000000000000000000000000036c3c2b5c96d1956a3c91b89817deb58c26085065aae9bca5828bbeef95317794600000000000000000000000094a9d9ac8a22534e3faca9f4e7f2e2cf85d5e4c8000000000000000000000000000000000000000000000000000000000000000100000000000000000000000067c0c572d2aa85be05061e5c63ef6c1d896c19280000000000000000000000000000000000000000000000000000000000000000) [delegatecall]
    │   │   │   ├─ [7468] 0x36B5dE936eF1710E1d22EabE5231b28581a92ECc::scaledTotalSupply() [staticcall]
    │   │   │   │   ├─ [2419] 0x54bdE009156053108E73E2401aEA755e38f92098::scaledTotalSupply() [delegatecall]
    │   │   │   │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000109fcfa43426
    │   │   │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000109fcfa43426
    │   │   │   ├─ [11676] 0x42A218F7bd03c63c4835496506492A383EfcF726::getSupplyData() [staticcall]
    │   │   │   │   ├─ [6615] 0xd1CF2FBf4fb82045eE0B116eB107d29246E8DCe9::getSupplyData() [delegatecall]
    │   │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000000000000002f7064d1587000000000000000000000000000000000000000000000000000002f7c03df8e40000000000000000000000000000000000000000002e40348e4d5d16db8aae470000000000000000000000000000000000000000000000000000000066cd8654
    │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000000000000002f7064d1587000000000000000000000000000000000000000000000000000002f7c03df8e40000000000000000000000000000000000000000002e40348e4d5d16db8aae470000000000000000000000000000000000000000000000000000000066cd8654
    │   │   │   ├─ [2924] 0x16dA4541aD1807f4443d92D26044C1147406EB80::scaledTotalSupply() [staticcall]
    │   │   │   │   ├─ [2375] 0x48424f2779be0f03cDF6F02E17A591A9BF7AF89f::scaledTotalSupply() [delegatecall]
    │   │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000000000000014cbfd8bc5a4
    │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000000000000014cbfd8bc5a4
    │   │   │   ├─ [7176] 0x5CB1008969a2d5FAcE8eF32732e6A306d0D0EF2A::calculateInterestRates((0, 1, 0, 3263105464548 [3.263e12], 20096523826599 [2.009e13], 55913788641822711573294663 [5.591e25], 1000, 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, 0x16dA4541aD1807f4443d92D26044C1147406EB80)) [staticcall]
    │   │   │   │   ├─ [2605] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::balanceOf(0x16dA4541aD1807f4443d92D26044C1147406EB80) [staticcall]
    │   │   │   │   │   └─ ← [Return] 1390770788175 [1.39e12]
    │   │   │   │   └─ ← [Return] 0x000000000000000000000000000000000000000000bc8dccb03be081a9cecb6d00000000000000000000000000000000000000000106eb1f239daadcb22e756e000000000000000000000000000000000000000000fa82bf827fa8f0432e756e
    │   │   │   ├─ emit ReserveDataUpdated(reserve: 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, liquidityRate: 227947683596416363373972333 [2.279e26], stableBorrowRate: 317848895277968722924303726 [3.178e26], variableBorrowRate: 302848895277968722924303726 [3.028e26], liquidityIndex: 1076440338475449308452363599 [1.076e27], variableBorrowIndex: 1099458239234877853025520263 [1.099e27])
    │   │   │   ├─ [13574] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::transferFrom(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0x16dA4541aD1807f4443d92D26044C1147406EB80, 1)
    │   │   │   │   ├─ emit Transfer(from: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, to: 0x16dA4541aD1807f4443d92D26044C1147406EB80, amount: 1)
    │   │   │   │   ├─ emit Approval(owner: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, spender: 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951, amount: 0)
    │   │   │   │   └─ ← [Return] true
    │   │   │   ├─ [45082] 0x16dA4541aD1807f4443d92D26044C1147406EB80::mint(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 1, 1076440338475449308452363599 [1.076e27])
    │   │   │   │   ├─ [44515] 0x48424f2779be0f03cDF6F02E17A591A9BF7AF89f::mint(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 1, 1076440338475449308452363599 [1.076e27]) [delegatecall]
    │   │   │   │   │   ├─ [7701] 0x4DA5c4da71C5a167171cC839487536d86e083483::handleAction(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 22866364712356 [2.286e13], 0)
    │   │   │   │   │   │   ├─ [2675] 0xDe7562059fE64B3D088a26a3F8B60e77dCb81ebE::handleAction(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 22866364712356 [2.286e13], 0) [delegatecall]
    │   │   │   │   │   │   │   └─ ← [Stop]
    │   │   │   │   │   │   └─ ← [Return]
    │   │   │   │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, amount: 1)
    │   │   │   │   │   ├─ emit Mint(param0: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, param1: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, param2: 1, param3: 0, param4: 1076440338475449308452363599 [1.076e27])
    │   │   │   │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000000000000001
    │   │   │   │   └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000000000000001
    │   │   │   ├─ emit ReserveUsedAsCollateralEnabled(reserve: 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, user: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928)
    │   │   │   ├─ emit Supply(reserve: 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8, user: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, onBehalfOf: 0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, amount: 1, referralCode: 0)
    │   │   │   └─ ← [Stop]
    │   │   └─ ← [Stop]
    │   └─ ← [Return]
    ├─ [756] 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8::allowance(0x67C0C572D2AA85Be05061E5c63eF6C1d896C1928, 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951) [staticcall]
    │   └─ ← [Return] 0
    └─ ← [Stop]


==========================

Chain 11155111

Estimated gas price: 47.87788564 gwei

Estimated total gas used for script: 474690

Estimated amount required: 0.0227271535344516 ETH

==========================

##### sepolia
✅  [Success]Hash: 0x17d8e0650df0a08d9511893a09b78d4c2669e8bafec7f1704adb4f0bdd50693f
Block: 6619192
Paid: 0.001103146079582328 ETH (46203 gas * 23.876070376 gwei)


##### sepolia
✅  [Success]Hash: 0x57eae62ca00884538050c4b54b54cf557347222943cd47831c238db43b576c94
Block: 6619192
Paid: 0.001304254220359376 ETH (54626 gas * 23.876070376 gwei)


##### sepolia
✅  [Success]Hash: 0xf1855a20c18d3f323eb80216ae52c968cf58a85f111f7d79af24ea1c5fbba370
Block: 6619192
Paid: 0.005342199118418872 ETH (223747 gas * 23.876070376 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.007749599418360576 ETH (324576 gas * avg 23.876070376 gwei)


==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Transactions saved to: /home/ak/somm/cellar-contracts/broadcast/AaveDepositWithSelfApprovalScript.s.sol/11155111/run-latest.json

Sensitive values saved to: /home/ak/somm/cellar-contracts/cache/AaveDepositWithSelfApprovalScript.s.sol/11155111/run-latest.json
*/
