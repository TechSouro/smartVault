// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import "../src/TesouroDireto.sol";
import "../src/mercadoAberto.sol";
import "../test/mocks/mockERC20DREX.sol"; //DREX with compliance and onchain verification
import "./Helper.sol";
import {tesouroDireto} from "../src/TesouroDireto.sol";
import {DestinationMinter} from "../src/cross-chain-nft-minter/DestinationMinterTesouro.sol";
import {SourceMinter} from "../src/cross-chain-nft-minter/SourceMinterTesouro.sol";

//Vault and OracleDREX
import {oracleDrex} from "../src/oracleDREX.sol";

import {VaultSimple} from "../src/VaultSimple.sol";
import "../test/mocks/mockERC20DREX.sol";



contract DeployDestination is Script, Helper {

    tesouroDireto public tesourodireto;
    openMarket public mercadoAberto;
    //mockERC20 public mockErc20;


    VaultSimple public vaultSimple;
     oracleDrex public oracleDREX;
    

    address public owner = makeAddr("owner"); //also the emitter
    address public union = makeAddr("union");
    address public user = makeAddr("user");

    

    function run(SupportedNetworks destination) external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(senderPrivateKey);

        (address router, , , ) = getConfigFromNetwork(destination);

        
        oracleDREX = new oracleDrex();
        // oracleDREX.mintTest(0xAaa7cCF1627aFDeddcDc2093f078C3F173C46cA4, 10000); //mint 100 DREX
        oracleDREX.mint(0x53318BF24EB52341b882b947b3761A5e22a15e76,10000000);
        oracleDREX.mint(0x53318BF24EB52341b882b947b3761A5e22a15e76,10000000);
        oracleDREX.mint(0xAaa7cCF1627aFDeddcDc2093f078C3F173C46cA4,10000000);
        
        //0xAaa7cCF1627aFDeddcDc2093f078C3F173C46cA4

        vaultSimple = new VaultSimple(address(oracleDREX));

        mercadoAberto = new openMarket("testURI", address(oracleDREX), 0x5bb7dd6a6eb4a440d6C70e1165243190295e290B);
    
        mercadoAberto.KYC(0x5bb7dd6a6eb4a440d6C70e1165243190295e290B);
        mercadoAberto.KYC(0x53318BF24EB52341b882b947b3761A5e22a15e76);
        mercadoAberto.KYC(0xAaa7cCF1627aFDeddcDc2093f078C3F173C46cA4);
        oracleDREX.approve(address(mercadoAberto), 100000000000000000000000);
        oracleDREX.mint(address(mercadoAberto), 1000000000000);



//0x53318BF24EB52341b882b947b3761A5e22a15e76
        console2.log("Address of oracleDREX: ", address(oracleDREX));
        console2.log("Address of mercadoAberto: ", address(mercadoAberto));
        console2.log("Address of Vault: ", address(vaultSimple));
        
        
        // vm.stopPrank();

<<<<<<< Updated upstream
        tesouroDireto myNFT = new tesouroDireto("Tesouro Direto", "TD", address(mercadoAberto), address(oracleDREX));
=======
        tesourodireto = new tesouroDireto("Tesouro Direto", "TD", address(mercadoAberto), address(mockErc20));
        mercadoAberto.setTreasury(address(tesourodireto));
>>>>>>> Stashed changes

        console2.log(
            "tesourodireto deployed on ",
            networks[destination],
            "with address: ",
            address(tesourodireto)
        );

        DestinationMinter destinationMinter = new DestinationMinter(
            router,
            address(tesourodireto)
        );

        console2.log(
            "DestinationMinter deployed on ",
            networks[destination],
            "with address: ",
            address(destinationMinter)
        );

<<<<<<< Updated upstream
        myNFT.setEmmiter(address(destinationMinter));
        myNFT.setEmmiter(address(destinationMinter));
        myNFT.setEmmiter(0x53318BF24EB52341b882b947b3761A5e22a15e76);
        myNFT.setEmmiter(0x53318BF24EB52341b882b947b3761A5e22a15e76);
        myNFT.transferOwnership(address(destinationMinter));
        address minter = myNFT.owner();
=======
        tesourodireto.setEmmiter(address(destinationMinter));
        tesourodireto.transferOwnership(address(destinationMinter));
        address minter = tesourodireto.owner();
>>>>>>> Stashed changes

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
