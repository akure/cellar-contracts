// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {AaveV3ATokenAdaptor} from "src/modules/adaptors/Aave/V3/AaveV3ATokenAdaptor.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract AaveDepositScript is Script {
    // Aave V3 Sepolia addresses
    address public aaveAdaptorAddress = 0x91542358C085f4fbce50194B3Ddb293E12db0F7a; // Previously deployed AaveV3ATokenAdaptor address
    ERC20 public testUSDC = ERC20(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238); // USDC on Sepolia testnet

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(privateKey);

        // Start broadcasting transactions to the network
        vm.startBroadcast(privateKey);
        console.log("Running AaveDepositScript:");

        // Deposit 0.001 USDC (with 6 decimal places, it is 1000 units)
        deposit(sender, 1000); // 0.001 USDC in smallest units

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }

    function deposit(address sender, uint256 depositAmount) internal {
        console.log("Starting deposit:");

        // Initialize the AaveV3ATokenAdaptor contract
        AaveV3ATokenAdaptor aaveAdaptor = AaveV3ATokenAdaptor(aaveAdaptorAddress);

        // Check the allowance before attempting the transfer
        // uint256 allowance = testUSDC.allowance(sender, address(aaveAdaptor));
        // console.log("Current allowance for aaveAdaptor:", allowance);
        testUSDC.approve(address(this), depositAmount);
        // approve(address spender, uint256 amount)

        // Ensure the adaptor has enough approval from the sender
        // require(allowance >= depositAmount, "Not enough allowance from the sender");

        // Transfer USDC from sender to the aaveAdaptor contract
        console.log("Transferring USDC from sender to the aaveAdaptor...");
        // bool success = testUSDC.transferFrom(sender, address(aaveAdaptor), depositAmount);
        bool success = testUSDC.transferFrom(sender, address(aaveAdaptor), depositAmount);

        require(success, "Transfer failed");
        console.log("Transferred", depositAmount, "USDC to aaveAdaptor.");

        // Encode the adaptor data with the USDC address
        bytes memory adaptorData = abi.encode(address(testUSDC));

        // Deposit the USDC into Aave via the AaveV3ATokenAdaptor
        console.log("Depositing USDC into Aave via AaveV3ATokenAdaptor...");
        aaveAdaptor.deposit(depositAmount, adaptorData, "");
        console.log("Deposit complete.");

        // Check the balance of the adaptor after deposit
        uint256 balance = testUSDC.balanceOf(address(aaveAdaptor));
        console.log("Adaptor USDC balance after deposit:", balance);
    }
}
