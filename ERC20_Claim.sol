// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract TKNToken is ERC20, Ownable {
    uint256 private _maxTokens = 1000000000 * 10e18;
    uint256 private _decimals = 18;
    uint256 private timer = 0;
    string private _symbol = "TKN";
    string private _name = "Token";

    mapping(address => uint256) public Timestamp; 

    bool public claimStatus = false;

    constructor() ERC20(_name, _symbol) {

    }

// ----- Token Control -----
 

    function mint(uint256 amount) external onlyOwner {
        _mint(msg.sender, amount);
    }
    
    function mintToClaim(uint256 amount) external onlyOwner{
        _mint(address(this), amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

// ----- Claim -----

    function Claim (uint256 amount) external {

        uint256 currentTime = block.timestamp;
        require(Timestamp[msg.sender] <= currentTime, "Not Claim Time, Not yet");
        require(claimStatus == true, "Claim locked");

        approve(msg.sender, amount);
        _transfer(address(this), msg.sender, amount);
        uint256 ClaimTime = block.timestamp + timer;
        Timestamp[msg.sender] = ClaimTime;

    }

// ----- Settings -----

    function setMaxTokens(uint256 newMax) external onlyOwner {
        _maxTokens = newMax;
    }

    function SetTimeOut(uint256 newTime) external onlyOwner {
        timer = newTime;
    }

    function ClaimUnlock() external onlyOwner {
        claimStatus = true;
    }
    
    function ClaimLock() external onlyOwner {
        claimStatus = false;
    }

// ----- View Parameters -----

    function AcctTimeLeft(address account) public view returns(uint256) {
        uint256 currentTime = block.timestamp;
        uint256 leftTime = Timestamp[account] - currentTime;
        return leftTime;
    }
    
    function TimeLeft() public view returns(uint256) {
        uint256 currentTime = block.timestamp;
        uint256 leftTime = Timestamp[msg.sender] - currentTime;
        return leftTime;
    }
        
    function TimeOut() public view returns(uint256){
        return timer;
    }

}