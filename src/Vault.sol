// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.21;


import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Vault is ERC20Burnable {
    IERC20 public immutable token;

    mapping(address => bool) public authorizedAddresses;
    mapping(address => bool) public governor;

    constructor(address _token) ERC20("TESOURO","TSO"){
        token = IERC20(_token);

    }

    //events
    event UpdatedAuthorization(address indexed target, bool authorized);
    event NewGovernor(address indexed governor, bool authorized);

    function mint(address _to, uint _shares) public {
        _mint(_to, _shares);
    }

     function _burn(uint _shares) public {
        burn( _shares);
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

}

//https://github.com/opynfinance/perp-vault-templates