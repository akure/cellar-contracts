// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {AaveV3ATokenAdaptor} from "src/modules/adaptors/Aave/V3/AaveV3ATokenAdaptor.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
// source .env && forge script script/Sepolia/AaveBalanceCheckScript.s.sol:AaveBalanceCheckScript --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
contract AaveBalanceCheckScript is Script {
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
        console.log("Address of adapter  contract:", address(aaveAdaptorAddress));
        console.log("Address of testUSDC:", address(testUSDC));

        // Check the contract's balance directly
        uint256 balance1 = testUSDC.balanceOf(sender);
        console.log("Caller USDC balance:", balance1);

        uint256 balance2 = testUSDC.balanceOf(address(this));
        console.log("This Contract USDC balance:", balance2);

        uint256 balance3 = testUSDC.balanceOf(aaveAdaptorAddress);
        console.log("aaveAdaptorAddress Contract USDC balance:", balance3);

        //uint256 balance4 = testUSDC.balanceOf(testUSDC);
        //console.log("testUSDC balance:", balance4);


        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}