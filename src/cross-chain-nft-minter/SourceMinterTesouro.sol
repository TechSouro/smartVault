// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LinkTokenInterface} from "../interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/ccip/libraries/Client.sol";
import {Withdraw} from "../utils/Withdraw.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract SourceMinter is Withdraw {
    enum PayFeesIn {
        Native,
        LINK
    }

     enum treasuryType{
        LTN, //PREFIXADO,O investidor conhece o retorno exato ao final da aplicação
        NTN_F, //descrito acima e que são pagos juros semestrais ao investidor 
        LFT, //POS-FIXADO que acompanha a variação da taxa Selic diariamente
        NTN_B_MAIN, //MISTO, combinando rentabilidade prefixada com o IPCA,
        NTN_B ////descrito acima e que são pagos juros semestrais ao investidor 
    }

    struct treasuryData{
        treasuryType _type;
        uint24 _apy;
        uint256 _minInvestment;
        uint256 _validThru;
        uint256 _avlbTokens;
        uint256 _creation;
    }


    address immutable i_router;
    address immutable i_link;

    event MessageSent(bytes32 messageId);

    constructor(address router, address link) {
        i_router = router;
        i_link = link;
    }

    receive() external payable {}

    function emission(
        uint64 destinationChainSelector,
        address receiver,
        PayFeesIn payFeesIn,
        treasuryData memory _data
    ) external {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encodeWithSignature("emitTreasury(treasuryType,uint24,uint256,uint256,uint256,uint256)", _data),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: payFeesIn == PayFeesIn.LINK ? i_link : address(0)
        });

        uint256 fee = IRouterClient(i_router).getFee(
            destinationChainSelector,
            message
        );

        bytes32 messageId;

        if (payFeesIn == PayFeesIn.LINK) {
            LinkTokenInterface(i_link).approve(i_router, fee);
            messageId = IRouterClient(i_router).ccipSend(
                destinationChainSelector,
                message
            );
        } else {
            messageId = IRouterClient(i_router).ccipSend{value: fee}(
                destinationChainSelector,
                message
            );
        }

        emit MessageSent(messageId);
    }
}
