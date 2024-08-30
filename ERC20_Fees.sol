// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract TKN_Contract is ERC20, AccessControl {
    uint256 public maxSupply;
    uint256 private totalTokens;
    uint256 public feeRate = 0;
    address private feeWallet;
    bytes32 public constant FREE_ROLE = keccak256("FREE_ROLE");

    bool onlyContractFees = false;

    constructor() ERC20("Token Name", "TKN") {
        maxSupply = 1000000000 * 10e18;
        feeWallet = msg.sender;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(uint256 amount) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin Role required");
        totalTokens = totalSupply();
        require(amount + totalTokens <= maxSupply, "Exceeded amount of tokens");
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function transfer(address recipient, uint256 amount) public override  virtual returns (bool){
        require(recipient != address(0), "ERC20: transfer to the zero address");
        address sender = _msgSender();
        uint256 fee = amount / 100 * feeRate;
        // if only for contract transfer fees applied, check address
        if (onlyContractFees == true) {
            bool checkAddr = _isContract(recipient);
            // if contract - apply fee
            if (checkAddr == true) {
                fee = amount / 100 * feeRate;
            }
            else fee = 0;
        }
        // whitelist role
        if (hasRole(FREE_ROLE, msg.sender)) {
            fee = 0;
        }
        if (fee != 0) {
            _transfer(sender, feeWallet, fee);
        }
        _transfer(sender, recipient, amount-fee);
        
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override virtual returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        address spender = _msgSender();
        uint256 fee = amount / 100 * feeRate;
        if (onlyContractFees == true) {
            bool checkAddr = _isContract(recipient);
            if (checkAddr == true) {
                fee = amount / 100 * feeRate;
            }
            else fee = 0;
        }
        if (hasRole(FREE_ROLE, msg.sender)) {
            fee = 0;
        }
        _spendAllowance(sender, spender, amount);
        if (fee != 0) {
            _transfer(sender, feeWallet, fee);
        }
        _transfer(sender, recipient, amount-fee);
        
        return true;
    }

    function _isContract(address addr) public view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


    function setMaxTokens(uint newMax) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin Role required");
        totalTokens = totalSupply();
        require(newMax > totalTokens, "You need to burn some first");
        maxSupply = newMax;
    }

    function setFeeRate(uint256 newFee) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin Role required");
        feeRate = newFee;
    }

    function setFeeWallet (address newWallet) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin Role required");
        require(newWallet != address(0), "Fee reciever wallet can't be zero address");
        feeWallet = newWallet;
    }

    function setContractFee () external returns(bool){
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Admin Role required");
        if (onlyContractFees == true) { onlyContractFees = false; }
        else if (onlyContractFees == false) { onlyContractFees = true; }
        return onlyContractFees;
    }

}



