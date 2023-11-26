// SPDX-License-Identifier: UNLICENSED
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

    /// @dev state of the oracle before it was paused
    State public stateBeforePause;

    /// @dev the timestamp at which the current oracle started
    uint256 public startTime;

    mapping(address => bool) public authorizedAddresses;
    mapping(address => bool) public governor;


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
