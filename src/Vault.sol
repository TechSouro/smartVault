// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.21;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeMath} from "./utils/SafeMath.sol";

contract Vault is ERC20Upgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    //IERC20 public immutable token;

    enum VaultState {Locked, Unlocked, Emergency}
    //State for user and security transactions

    /// @dev current state of the vault
    VaultState public state;

    /// @dev state of the vault before it was paused
    VaultState public stateBeforePause;

    /// @dev the timestamp at which the current Vault started
    uint256 public currentVaultStartTimestamp;

    mapping(address => bool) public authorizedAddresses;
    mapping(address => bool) public governor;


    /*=====================
    *       Events       *
    *====================*/

    event Deposit(address account, uint256 amountDeposited, uint256 shareMinted);

    event Withdraw(address account, uint256 amountWithdrawn, uint256 shareBurned);

    event StateUpdated(VaultState state);
    event UpdatedAuthorization(address indexed target, bool authorized);
    event NewGovernor(address indexed governor, bool authorized);
    


    /*=====================
   * External Functions *
   *====================*/

  /**
   * @notice function to init the vault
   * this will set the "action" for this strategy vault and won't be able to change
   * @param _asset The asset that this vault will manage. Cannot be changed after initializing.
   * @param _owner The address that will be the owner of this vault.
   * @param _feeRecipient The address to which all the fees will be sent. Cannot be changed after initializing.
   * @param _weth address of WETH
   * @param _decimals of the _asset
   * @param _tokenName name of the share given to depositors of this vault
   * @param _tokenSymbol symbol of the share given to depositors of this vault
   * @param _actions array of addresses of the action contracts
   * @dev when choosing actions make sure they have similar lifecycles and expiries. if the actions can't all be closed at the
   * same time, composing them may lead to tricky interactions like user funds being stuck for longer in actions than expected. 
   */
  function init(
    address _asset,
    address _owner,
    address _feeRecipient,
    address _weth,
    uint8 _decimals,
    string memory _tokenName,
    string memory _tokenSymbol,
    address[] memory _actions
  ) public initializer {
    __ReentrancyGuard_init();
    __ERC20_init(_tokenName, _tokenSymbol);
    //_setupDecimals(_decimals);
    __Ownable_init(_owner);
    //transferOwnership(_owner);

    //asset = _asset;
    //feeRecipient = _feeRecipient;
    //WETH = _weth;

    // assign actions
    // for (uint256 i = 0; i < _actions.length; i++) {
    //   // check all items before actions[i], does not equal to action[i]
    //   for (uint256 j = 0; j < i; j++) {
    //     require(_actions[i] != _actions[j], "duplicated action");
    //   }
    //   actions.push(_actions[i]);
    // }

    state = VaultState.Unlocked;

    currentVaultStartTimestamp = block.timestamp;
  }



    function mint(address _to, uint _shares) public {
        _mint(_to, _shares);
    }

     function burn(address _user,uint _shares) public {
        _onlyGovernor();
        _burn(_user, _shares);
     }



     function setAuthorized(address _target, bool _value) external {
        _onlyGovernor();
        authorizedAddresses[_target] = _value;
        emit UpdatedAuthorization(_target, _value);
    }

    function setGovernor(address _governance, bool _value) external {
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

        /*=====================
    *     Modifiers      *
    *====================*/

    /**
     * @dev can only be executed in the unlocked state.
     */
    modifier onlyUnlocked {
        require(state == VaultState.Unlocked, "!Unlocked");
        _;
    }

    /**
     * @dev can only be executed in the locked state.
     */
    modifier onlyLocked {
        require(state == VaultState.Locked, "!Locked");
        _;
    }

    /**
     * @dev can only be executed in the unlocked state. Sets the state to 'Locked'
     */
    modifier lockState {
        state = VaultState.Locked;
        emit StateUpdated(VaultState.Locked);
        _;
    }

    /**
     * @dev Sets the state to 'Unlocked'
     */
    modifier unlockState {
        state = VaultState.Unlocked;
        emit StateUpdated(VaultState.Unlocked);
        _;
    }

    /**
     * @dev can only be executed if vault is not in the 'Emergency' state.
     */
    modifier notEmergency {
        require(state != VaultState.Emergency, "Emergency");
        _;
    }

}

//https://github.com/opynfinance/perp-vault-templates