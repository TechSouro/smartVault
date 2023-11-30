// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import "./Helper.sol";
import {VaultSimple} from "../src/VaultSimple.sol";
import "../test/mocks/mockERC20DREX.sol";


contract DeployVault is Script {

VaultSimple public vaultSimple;
mockERC20 public mockErc20;
function run() external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);


        // vm.startPrank(owner);
        mockErc20 = new mockERC20();
        vaultSimple = new VaultSimple(address(mockErc20));
        

        console2.log("Address of vaultSimple: ", address(vaultSimple));
        
        vm.stopBroadcast();
    }
}

