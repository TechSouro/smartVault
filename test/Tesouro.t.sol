// SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import "forge-std/Test.sol";
// import "forge-std/console.sol";
// import "../src/TesouroDireto.sol";
// import "../src/mercadoAberto.sol";
// import "./mocks/mockERC20DREX.sol";
// import "../test/mocks/mockERC3643.sol";
// import {OracleDREXerc3643} from "../src/OracleDREXerc3643.sol";
// import "../lib/ERC-3643/contracts/compliance/modular/ModularCompliance.sol";

// contract Tesouro is Test {
//     tesouroDireto public tesourodireto;
//     openMarket public mercadoAberto;
//     mockERC20 public mockErc20;

//     // OracleDREXerc3643 public mockErc20;
//     ModularCompliance public compliance;

//     address public owner = makeAddr("owner"); //also the emitter
//     address public union = makeAddr("union");
//     address public user = makeAddr("user");


//     function setUp() public {
//         vm.startPrank(owner);

//         // compliance = new ModularCompliance();
//         // mockErc20 = new OracleDREXerc3643();
//         // mockErc20.init(owner, owner, address(compliance));//initializer
//         // mockErc20.mintTest(owner, 10000); //mint 100 DREX
//         mockErc20 = new mockERC20();
//         mercadoAberto = new openMarket("testURI", address(mockErc20), union);
//         tesourodireto = new tesouroDireto("Tesouro Direto", "TD", address(mercadoAberto), address(mockErc20));
//         mercadoAberto.setTreasury(address(tesourodireto));
//         mercadoAberto.KYC(user);

//         console.log("Address of mercadoAberto: ", address(mercadoAberto));
//         console.log("Address of tesourodireto: ", address(tesourodireto));
        
//         vm.stopPrank();
//     }

//     function testCreateTesouroDireto() public {
//         tesouroDireto.treasuryType _enum = tesouroDireto.treasuryType.LFT;
//         tesouroDireto.treasuryData memory _data = tesouroDireto.treasuryData({
//             _type: _enum,
//             _apy: 1000,
//             _minInvestment: 1 ether,
//             _validThru: 365 days * 10,
//             _avlbTokens: 100,
//             _creation: 0
//         });
//         vm.prank(owner,owner);
//         tesourodireto.emitTreasury(_data);
//         vm.prank(owner,owner);
//         tesourodireto.openPublicOffer(0);
//         console.log("Balance of mercado Aberto: ", tesourodireto.balanceOf(address(mercadoAberto)));
//         console.log("Owner of token 0: ", tesourodireto.ownerOf(0));

//         (uint256 _available, uint256 _pric) = mercadoAberto.getOpenBuy(0);

//         console.log("Open Buy Amount available: ", _available);
//         console.log("Open Buy Price min.: ", _pric);

//         console.log("Balance of token 0 mercadoAberto 1155: ", mercadoAberto.balanceOf(address(mercadoAberto),0));
//     }

//     function testPrimarySale() public {
//         testCreateTesouroDireto();

//         vm.startPrank(user);
//         mockErc20.mint( 3 ether);
//         mockErc20.approve(address(mercadoAberto), 2 ether);
//         console.log("wDrex balance of user previous to purchase: ", mockErc20.balanceOf(user));
//         console.log("wDrex balance of union previous to purchase: ", mockErc20.balanceOf(union));

//         mercadoAberto.purchasePrimary(0, 2);

//         console.log("wDrex balance of user post to purchase: ", mockErc20.balanceOf(user));
//         console.log("wDrex balance of union post to purchase: ", mockErc20.balanceOf(union));
//         console.log("token 0 user ERC1155 balance of user post to purchase: ", mercadoAberto.balanceOf(user, 0));
//         console.log("token 0 mercado aberto ERC1155 balance of user post to purchase: ", mercadoAberto.balanceOf(address(mercadoAberto), 0));

//         vm.stopPrank();
//     }

//     function testSecondarySale() public {
//         testPrimarySale();
        
//         vm.startPrank(user);

//         mercadoAberto.setApprovalForAll(address(mercadoAberto), true);
//         mercadoAberto.sellMyUnits(0, 1, 3 ether);
        
//         (uint256 _available, uint256 _pric) = mercadoAberto.getSecondaryMarket(0, user);
//         console.log("Units put for sale on secondary of token 0: ", _available);
//         console.log("Price put for sale on secondary of token 0: ", _pric);

//         vm.stopPrank();

//         vm.startPrank(owner);
//         mockErc20.approve(address(mercadoAberto), 3 ether);

//         console.log("wDrex balance of user previous to purchase: ", mockErc20.balanceOf(user));
//         console.log("wDrex balance of owner previous to purchase: ", mockErc20.balanceOf(owner));

//         mercadoAberto.buySecondary(user, 0, 1);


//         console.log("wDrex balance of user post to purchase: ", mockErc20.balanceOf(user));
//         console.log("wDrex balance of owner post to purchase: ", mockErc20.balanceOf(owner));
//     }

//     function testRetrieval() public {
//         testPrimarySale();
//         console.log("wDrex balance of wDrex previous to retrieval: ", mockErc20.balanceOf(address(mockErc20)));
//         mockErc20.mintInternal(10 ether);
//         console.log("wDrex balance of wDrex previous to retrieval: ", mockErc20.balanceOf(address(mockErc20)));
//         mockErc20.approveExternal(address(tesourodireto), 10 ether);
//         vm.warp(block.timestamp + (365 days*10));
        
//         vm.startPrank(user,user);
//         console.log("wDrex balance of user previous to retrieval: ", mockErc20.balanceOf(user));
//         mercadoAberto.setApprovalForAll(address(mercadoAberto), true);
//         mercadoAberto.retrieveInvestment(0, 2);
//         console.log("wDrex balance of wDres post to retrieval: ", mockErc20.balanceOf(address(mockErc20)));
//         console.log("wDrex balance of user post to retrieval: ", mockErc20.balanceOf(user));
//         vm.stopPrank();
//     }


//     function testCreateTesouroWithEncode() public {
//         tesouroDireto.treasuryType _enum = tesouroDireto.treasuryType.LFT;
//         tesouroDireto.treasuryData memory _data = tesouroDireto.treasuryData({
//             _type: _enum,
//             _apy: 1000,
//             _minInvestment: 1 ether,
//             _validThru: 365 days * 10,
//             _avlbTokens: 100,
//             _creation: 0
//         });
//         vm.prank(owner,owner);
//         address(tesourodireto).call(abi.encodeWithSignature("emitTreasury((uint8,uint24,uint256,uint256,uint256,uint256))", _data));
//         // tesourodireto.emitTreasury(_data);
//         console.log("Balance of mercado Aberto: ", tesourodireto.balanceOf(address(mercadoAberto)));
//         console.log("Owner of token 0: ", tesourodireto.ownerOf(0));

//         (uint256 _available, uint256 _pric) = mercadoAberto.getOpenBuy(0);

//         console.log("Open Buy Amount available: ", _available);
//         console.log("Open Buy Price min.: ", _pric);

//         console.log("Balance of token 0 mercadoAberto 1155: ", mercadoAberto.balanceOf(address(mercadoAberto),0));
//     }
// }