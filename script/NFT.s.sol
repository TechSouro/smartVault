// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import "./Helper.sol";
import {Ibmec} from "../src/NFT.sol";
import "../test/mocks/mockERC20DREX.sol";


contract Deployibmec is Script {

Ibmec public ibmec;
function run() external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);


        // vm.startPrank(owner);
        ibmec = new Ibmec();
        

        console2.log("ibmec: ", address(ibmec));
        
        vm.stopBroadcast();
    }
}

