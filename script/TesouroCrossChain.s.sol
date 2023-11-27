// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import "../src/TesouroDireto.sol";
import "../src/mercadoAberto.sol";
import "../test/mocks/mockERC20DREX.sol";
import "./Helper.sol";
import {tesouroDireto} from "../src/TesouroDireto.sol";
import {DestinationMinter} from "../src/cross-chain-nft-minter/DestinationMinterTesouro.sol";
import {SourceMinter} from "../src/cross-chain-nft-minter/SourceMinterTesouro.sol";

contract DeployDestination is Script, Helper {

    tesouroDireto public tesourodireto;
    openMarket public mercadoAberto;
    mockERC20 public mockErc20;


    address public owner = makeAddr("owner"); //also the emitter
    address public union = makeAddr("union");
    address public user = makeAddr("user");

     

    function run(SupportedNetworks destination) external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

        (address router, , , ) = getConfigFromNetwork(destination);

        // vm.startPrank(owner);

        mockErc20 = new mockERC20();
        mercadoAberto = new openMarket("testURI", address(mockErc20), 0x5bb7dd6a6eb4a440d6C70e1165243190295e290B);
    
        mercadoAberto.setTreasury(address(tesourodireto));
        mercadoAberto.KYC(0x5bb7dd6a6eb4a440d6C70e1165243190295e290B);

        console2.log("Address of mercadoAberto: ", address(mercadoAberto));
        console2.log("Address of tesourodireto: ", address(tesourodireto));
        
        // vm.stopPrank();

        tesouroDireto myNFT = new tesouroDireto("Tesouro Direto", "TD", address(mercadoAberto), address(mockErc20));

        console2.log(
            "tesourodireto deployed on ",
            networks[destination],
            "with address: ",
            address(myNFT)
        );

        DestinationMinter destinationMinter = new DestinationMinter(
            router,
            address(myNFT)
        );

        console2.log(
            "DestinationMinter deployed on ",
            networks[destination],
            "with address: ",
            address(destinationMinter)
        );

        myNFT.setEmmiter(address(destinationMinter));
        myNFT.transferOwnership(address(destinationMinter));
        address minter = myNFT.owner();

        console2.log("Minter role granted to: ", minter);

        vm.stopBroadcast();
    }
}

contract DeploySource is Script, Helper {
    function run(SupportedNetworks source) external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

        (address router, address link, , ) = getConfigFromNetwork(source);

        SourceMinter sourceMinter = new SourceMinter(router, link);

        console2.log(
            "SourceMinter deployed on ",
            networks[source],
            "with address: ",
            address(sourceMinter)
        );

        vm.stopBroadcast();
    }
}

contract Mint is Script, Helper {

    //
    function run(
        address payable sourceMinterAddress,
        SupportedNetworks destination,
        address destinationMinterAddress,
        SourceMinter.PayFeesIn payFeesIn,
        SourceMinter.treasuryData memory _data
    ) external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

        (, , , uint64 destinationChainId) = getConfigFromNetwork(destination);

        SourceMinter(sourceMinterAddress).emission(
            destinationChainId,
            destinationMinterAddress,
            payFeesIn,
            _data
        );

        vm.stopBroadcast();
    }
}
