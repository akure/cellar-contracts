// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import {Registry} from "src/Registry.sol";
// Other method to get byte code -
// forge inspect Registry bytecode > registryBytecode.txt

contract SaveBytecode is Script {
    function run() external {
        bytes memory creationCode = type(Registry).creationCode;
        console.logBytes(creationCode);
    }
}
