// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import "forge-std/Test.sol";
import {AaveV3ATokenAdaptor} from "src/modules/adaptors/Aave/V3/AaveV3ATokenAdaptor.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {IPoolV3} from "src/interfaces/external/IPoolV3.sol";
import {IAaveToken} from "src/interfaces/external/IAaveToken.sol";
import {IAaveOracle} from "src/interfaces/external/IAaveOracle.sol";

/*
source .env && forge script script/Sepolia/DeployAVVEV3Cellar.s.sol:DeployAVVEV3Cellar --rpc-url $ETHEREUM_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
Running a Specific Function Without Broadcast (Simulation Mode)
forge test --match-path scripts/sepolia/TestAaveV3TokenAdaptor.s.sol --match-test testDeposit
Running a Specific Function With Broadcast (Live Deployment/Interaction)
forge test --fork-url <SEPOLIA_RPC_URL> --broadcast --match-path scripts/sepolia/TestAaveV3TokenAdaptor.s.sol --match-test testDeposit
With Debugging,
forge test --match-path test/Sepolia/TestAaveV3TokenAdaptor.t.sol --match-test testDeposit -vvvv
*/
contract AaveAdaptorTest is Test {
    // Aave V3 Sepolia addresses
    address public aaveV3Pool = 0x7Ee60D184C24Ef7AfC1Ec7Be59A0f448A0abd138;
    address public aaveV3Oracle = 0x2da88497588bf89281816106C7259e31AF45a663;
    ERC20 public aV3USDC = ERC20(0x16dA4541aD1807f4443d92D26044C1147406EB80);
    ERC20 public testUSDC = ERC20(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238);

    AaveV3ATokenAdaptor public aaveAdaptor;

    function setUp() public {
        console.log("setUp:");

        // Set a realistic minimum health factor (e.g., 1.01)
        uint256 minHealthFactor = 1.01e18;

        // Deploy the AaveV3ATokenAdaptor with the provided Pool, Oracle, and minimum health factor
        aaveAdaptor = new AaveV3ATokenAdaptor(aaveV3Pool, aaveV3Oracle, minHealthFactor);
        console.log("setUp:");


        // Allocate Sepolia ETH to the contract for testing purposes
        vm.deal(address(this), 0.5 ether); // Adjusted to 1 ether, considering limited Sepolia ETH
        console.log("setUp:");

    }

    function testCheckBalance() public {
        console.log("Starting testCheckBalance:");
        console.log("Address of this contract:", address(this));
        console.log("Address of testUSDC:", address(testUSDC));

        // Check the contract's balance directly
        try testUSDC.balanceOf(address(this)) returns (uint256 balance) {
            console.log("Contract USDC balance:", balance);
        } catch {
            console.log("Failed to get contract USDC balance.");
            fail();
        }
    }

    function testDeposit() public {
        console.log("Starting testDeposit:");

        // Pre-check balances of all relevant addresses before the operation
        uint256 contractBalance = aV3USDC.balanceOf(address(this));
        console.log("Contract USDC balance before:", contractBalance);

        uint256 adaptorBalanceBefore = aV3USDC.balanceOf(address(aaveAdaptor));
        console.log("Adaptor USDC balance before:", adaptorBalanceBefore);

        // Define the deposit amount
        uint256 depositAmount = 1 * 1e6; // 1 USDC (USDC has 6 decimals)
        console.log("Deposit Amount:", depositAmount);

        // Ensure that the test contract has the expected USDC balance
        deal(address(aV3USDC), address(this), depositAmount);
        console.log("Deal function executed. USDC sent to contract.");

        uint256 initialBalance = aV3USDC.balanceOf(address(this));
        console.log("Contract USDC balance after deal:", initialBalance);

        // Approve the AaveV3ATokenAdaptor to spend USDC
        bool approved = aV3USDC.approve(address(aaveAdaptor), depositAmount);
        console.log("USDC approved for adaptor:", approved);

        uint256 allowance = aV3USDC.allowance(address(this), address(aaveAdaptor));
        console.log("USDC allowance for adaptor after approval:", allowance);

        // Ensure the allowance is set correctly
        assertEq(allowance, depositAmount, "USDC allowance not set correctly");
        console.log("Allowance assertion passed.");

        // Encode the adaptor data with the aToken address
        bytes memory adaptorData = abi.encode(address(aV3USDC));
        console.log("Adaptor data encoded.");

        // Attempt the deposit operation
        try aaveAdaptor.deposit(depositAmount, adaptorData, "") {
            console.log("Deposit function executed.");

            // If deposit is successful, check the balance
            uint256 balance = aV3USDC.balanceOf(address(aaveAdaptor));
            console.log("Adaptor USDC balance after deposit:", balance);

            assertEq(balance, depositAmount, "Deposit failed: Balance does not match deposit amount");
            console.log("Deposit assertion passed.");
        } catch Error(string memory reason) {
            // Catch revert reason and log it
            console.log("Deposit reverted with reason:", reason);
            fail();
        } catch (bytes memory lowLevelData) {
            // Catch other low-level revert reasons
            console.log("Deposit failed with low-level revert");
            fail();
        }

        // Post-check balances of all relevant addresses after the operation
        uint256 contractBalanceAfter = aV3USDC.balanceOf(address(this));
        console.log("Contract USDC balance after:", contractBalanceAfter);

        uint256 adaptorBalanceAfter = aV3USDC.balanceOf(address(aaveAdaptor));
        console.log("Adaptor USDC balance after:", adaptorBalanceAfter);
    }




    /**
     * @dev Test the withdrawal functionality of the Aave V3 Adaptor using aV3USDC.
     */
    function testWithdraw() public {
        uint256 depositAmount = 1 * 1e6; // 1000 USDC

        // First, perform a deposit operation
        testDeposit();

        // Encode the adaptor data with the aToken address
        bytes memory adaptorData = abi.encode(address(aV3USDC));

        // Define the receiver address (in this case, the test contract itself)
        address receiver = address(this);

        // Perform the withdrawal operation
        aaveAdaptor.withdraw(depositAmount, receiver, adaptorData, "");

        // Verify that the withdrawal was successful by checking the receiver's balance
        uint256 balance = aV3USDC.balanceOf(receiver);
        assertEq(balance, depositAmount, "Withdraw failed: Balance does not match withdrawn amount");
    }

    /**
     * @dev Test the withdrawal with a strict health factor using aV3USDC.
     */
    function testHealthFactorTooLow() public {
        uint256 depositAmount = 1000 * 1e6; // 1000 USDC

        // First, perform a deposit operation
        testDeposit();

        // Encode configuration data with a very high minimum health factor
        bytes memory configData = abi.encode(5e18);

        // Expect the withdrawal to revert due to a low health factor
        vm.expectRevert(AaveV3ATokenAdaptor.AaveV3ATokenAdaptor__HealthFactorTooLow.selector);

        // Attempt to withdraw with a strict health factor requirement
        aaveAdaptor.withdraw(depositAmount, address(this), abi.encode(address(aV3USDC)), configData);
    }

    /**
     * @dev Test the withdrawable amount calculation based on the health factor using aV3USDC.
     */
    function testWithdrawableFrom() public {
        uint256 depositAmount = 1000 * 1e6; // 1000 USDC

        // First, perform a deposit operation
        testDeposit();

        // Encode the adaptor and configuration data
        bytes memory adaptorData = abi.encode(address(aV3USDC));
        bytes memory configData = abi.encode(1.1e18); // Set a reasonable minimum health factor

        // Check the amount that can be withdrawn without breaching the health factor
        uint256 withdrawable = aaveAdaptor.withdrawableFrom(adaptorData, configData);

        // Verify that the withdrawable amount is greater than zero
        assertGt(withdrawable, 0, "Withdrawable amount should be greater than zero");
    }

    /**
     * @dev Test the balance retrieval function of the Aave V3 Adaptor using aV3USDC.
     */
    function testBalanceOf() public {
        uint256 depositAmount = 1000 * 1e6; // 1000 USDC

        // First, perform a deposit operation
        testDeposit();

        // Encode the adaptor data with the aToken address
        bytes memory adaptorData = abi.encode(address(aV3USDC));

        // Retrieve the balance of the aToken in the adaptor
        uint256 balance = aaveAdaptor.balanceOf(adaptorData);

        // Verify that the balance matches the deposited amount
        assertEq(balance, depositAmount, "Balance does not match the expected value");
    }

    /**
     * @dev Test the asset retrieval function of the Aave V3 Adaptor using aV3USDC.
     */
    function testAssetOf() public {
        // Encode the adaptor data with the aToken address
        bytes memory adaptorData = abi.encode(address(aV3USDC));

        // Retrieve the underlying asset of the aToken
        ERC20 asset = aaveAdaptor.assetOf(adaptorData);

        // Verify that the underlying asset matches the expected ERC20 token (USDC)
        assertEq(address(asset), address(aV3USDC), "Asset does not match the expected underlying asset");
    }
}
