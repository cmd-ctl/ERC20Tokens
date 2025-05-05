// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract AutoForwarder {
    address payable public recipient;
    address owner;
    IERC20 public token;
    
    modifier onlyOwner {
        require(msg.sender == owner, "Not the owner!");
        _;
    }

    event ForwardedETH(address indexed from, uint256 amount);
    event ForwardedTKN(address indexed from, uint256 amount);

    constructor(address payable _recipient, address _tokenAddress) {
        require(_recipient != address(0), "Invalid recipient address");
        require(_tokenAddress != address(0), "Invalid token address");
        recipient = _recipient;
        token = IERC20(_tokenAddress);
        owner = msg.sender;
    }

    // forward ETH
    receive() external payable {
        require(msg.value > 0, "No ETH sent");

        (bool success, ) = recipient.call{value: msg.value}("");
        require(success, "Failed to forward ETH");

        emit ForwardedETH(msg.sender, msg.value);
    }

    // forward token
    function receiveToken(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        
        // send to contract
        bool received = token.transferFrom(msg.sender, address(this), amount);
        require(received, "Token transfer failed");

        // send to recipient
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to forward");

        bool success = token.transfer(recipient, balance);
        require(success, "Failed to forward token");

        emit ForwardedTKN(msg.sender, balance);
    }

    // change recipient
    function setRecipient(address payable _newRecipient) external onlyOwner {
        require(_newRecipient != address(0), "Invalid recipient address");
        recipient = _newRecipient;
    }

    // change forward token
    function setToken(address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0), "Invalid token address");
        token = IERC20(_tokenAddress);
    }
}
