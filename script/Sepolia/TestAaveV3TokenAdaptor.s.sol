// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import {AaveV3ATokenAdaptor} from "src/modules/adaptors/Aave/V3/AaveV3ATokenAdaptor.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {IPoolV3} from "src/interfaces/external/IPoolV3.sol";
import {IAaveToken} from "src/interfaces/external/IAaveToken.sol";
import {IAaveOracle} from "src/interfaces/external/IAaveOracle.sol";

contract AaveAdaptorScript is Script {
    // Aave V3 Sepolia addresses
    address public aaveV3Pool = 0x7Ee60D184C24Ef7AfC1Ec7Be59A0f448A0abd138;
    address public aaveV3Oracle = 0x2da88497588bf89281816106C7259e31AF45a663;
    ERC20 public aV3USDC = ERC20(0x16dA4541aD1807f4443d92D26044C1147406EB80);
    ERC20 public testUSDC = ERC20(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238);

    AaveV3ATokenAdaptor public aaveAdaptor;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(privateKey);

        // Start broadcasting transactions to the network
        vm.startBroadcast(privateKey);
        console.log("Running AaveAdaptorScript:");

        // Set a realistic minimum health factor (e.g., 1.01)
        uint256 minHealthFactor = 1.01e18;

        // Deploy the AaveV3ATokenAdaptor with the provided Pool, Oracle, and minimum health factor
        aaveAdaptor = new AaveV3ATokenAdaptor(aaveV3Pool, aaveV3Oracle, minHealthFactor);
        console.log("Deployed AaveV3ATokenAdaptor at:", address(aaveAdaptor));

        // Allocate Sepolia ETH to the contract for testing purposes
        //console.log("Sepolia ETH allocated to this contract:", 0.5 ether);

        // Perform the approval and deposit process
        approveAndDeposit(sender, 0.001 * 1e6); // 0.001 USDC

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }

    function approveAndDeposit(address sender, uint256 depositAmount) internal {
        console.log("Starting approveAndDeposit:");

        // Check current allowance
        uint256 allowance = testUSDC.allowance(sender, address(this));
        console.log("Current allowance for this contract:", allowance);

        // Check if allowance is sufficient
        if (allowance < depositAmount) {
            console.log("Allowance is insufficient. Approving now...");
            // Directly approve within the context of the broadcasted transaction
            testUSDC.approve(address(this), type(uint256).max);
            console.log("Approval complete.");
        } else {
            console.log("Sufficient allowance already exists.");
        }

        // Transfer USDC from msg.sender to this contract
        console.log("Transferring USDC from msg.sender to contract...");
        testUSDC.transferFrom(sender, address(this), depositAmount);
        console.log("Transferred", depositAmount, "USDC to contract.");

        // Now, deposit the USDC into Aave via the AaveV3ATokenAdaptor
        bytes memory adaptorData = abi.encode(address(testUSDC));
        console.log("Depositing USDC into Aave via AaveV3ATokenAdaptor...");
        aaveAdaptor.deposit(depositAmount, adaptorData, "");
        console.log("Deposit complete.");
    }
}
