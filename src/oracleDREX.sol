// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract oracleDrex is ERC20, Ownable(msg.sender) {

    enum State {Locked, Unlocked, Emergency}
    //State for user and security transactions

    /// @dev current state of the oracle
    State public state;
forge verify-contract 0x45c41FeDC33e85047B60D448FC4eF16981822A09 src/mercadoAberto.sol:openMarket --chain-id 11155111 --num-of-optimizations 1000000 --watch --constructor-args $(cast abi-encode "constructor(string,address,address)" "testURI" 0x60e20aC02Ccf5C35056C6b698DBbbe0e662bf1dB 0x5bb7dd6a6eb4a440d6C70e1165243190295e290B) \--etherscan-api-key ECJCCZZKNZEH8Z8P2EJ6GCE7G7YCRFTRZA


forge verify-contract 0x4978A4140DF1245d19430BAe86Aa954bD33BCf07 src/TesouroDireto.sol:tesouroDireto --chain-id 11155111 --num-of-optimizations 1000000 --watch --constructor-args $(cast abi-encode "constructor(string,string,address,address)" "Tesouro Direto" "TD" 0x45c41FeDC33e85047B60D448FC4eF16981822A09 0x60e20aC02Ccf5C35056C6b698DBbbe0e662bf1dB) \--etherscan-api-key ECJCCZZKNZEH8Z8P2EJ6GCE7G7YCRFTRZA

forge verify-contract 0x60e20aC02Ccf5C35056C6b698DBbbe0e662bf1dB src/OracleDREX.sol:oracleDrex --chain-id 11155111 --etherscan-api-key ECJCCZZKNZEH8Z8P2EJ6GCE7G7YCRFTRZA


forge verify-contract 0x45c41FeDC33e85047B60D448FC4eF16981822A09 src/mercadoAberto.sol:openMarket --chain-id 11155111 --num-of-optimizations 1000000 --watch --constructor-args $(cast abi-encode "constructor(string,address,address)" "testURI" 0x60e20aC02Ccf5C35056C6b698DBbbe0e662bf1dB 0x5bb7dd6a6eb4a440d6C70e1165243190295e290B) \--etherscan-api-key ECJCCZZKNZEH8Z8P2EJ6GCE7G7YCRFTRZA
Start verifying contract `0x45c41fedc33e85047b60d448fc4ef16981822a09`;


    /*=====================
    *       Events       *
    *====================*/


    event StateUpdated(State state);
    event UpdatedAuthorization(address indexed target, bool authorized);
    event NewGovernor(address indexed governor, bool authorized);
    


    /*=====================
   * External Functions *
   *====================*/

  constructor()ERC20("DREX", "sDREX"){
    state = State.Unlocked;
    startTime = block.timestamp;
  }



    function mint(address _to, uint _shares) public onlyUnlocked{
        _mint(_to, _shares);
    }

     function burn(address _user,uint _shares) public onlyUnlocked{
        _onlyGovernor();
        _burn(_user, _shares);
     }


     function setAuthorized(address _target, bool _value) external {
        _onlyGovernor();
        authorizedAddresses[_target] = _value;
        emit UpdatedAuthorization(_target, _value);
    }

    function setGovernor(address _governance, bool _value) external onlyOwner{
        _onlyGovernor();
        governor[_governance] = _value;
        emit NewGovernor(_governance, _value);
    }


     function _onlyAuthorized() internal view {
        require(authorizedAddresses[msg.sender] == true || governor[msg.sender] == true, "!authorized");
    }

    function _onlyGovernor() internal view {
        require(governor[msg.sender] == true, "!governor");
    }

    function emergencyPause() external onlyOwner {
    stateBeforePause = state;
    state = State.Emergency;
    emit StateUpdated(State.Emergency);
  }

  function setLock() external onlyOwner{
    stateBeforePause = state;
    state = State.Locked;
    emit StateUpdated(State.Locked);
  }


        /*=====================
    *     Modifiers      *
    *====================*/

    /**
     * @dev can only be executed in the unlocked state.
     */
    modifier onlyUnlocked {
        require(state == State.Unlocked, "!Unlocked");
        _;
    }

    /**
     * @dev can only be executed in the locked state.
     */
    modifier onlyLocked {
        require(state == State.Locked, "!Locked");
        _;
    }


}
