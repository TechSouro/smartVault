// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import "./Helper.sol";
import {Ibmec} from "../src/NFT.sol";
import "../test/mocks/mockERC20DREX.sol";
import "../src/mercadoAberto.sol";


contract Deployibmec is Script {

// Ibmec public ibmec;

openMarket public mercadoAberto;

function run() external {
        mercadoAberto = openMarket(0x45c41FeDC33e85047B60D448FC4eF16981822A09);
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

        // mercadoAberto.setTreasury(0x4978A4140DF1245d19430BAe86Aa954bD33BCf07);
        mercadoAberto.setApprovalForAll(address(mercadoAberto), true);
        // vm.startPrank(owner);
        // ibmec = new Ibmec();
        

        // console2.log("ibmec: ", address(ibmec));
        
        vm.stopBroadcast();
    }
}

