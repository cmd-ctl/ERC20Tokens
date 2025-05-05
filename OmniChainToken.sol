// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { OFT } from "@layerzerolabs/oft-evm/contracts/OFT.sol";

contract MyOFT is OFT {

    uint256 maxTokens;

    constructor(string memory _name, string memory _symbol, address _lzEndpoint, address _delegate, uint256 _maxTokens) 
    OFT(_name, _symbol, _lzEndpoint, _delegate) 
    Ownable(_delegate) {
        maxTokens = _maxTokens;
    }

    
    function mint(uint256 amount) external onlyOwner {
        uint256 totalTokens = totalSupply();
        require(amount + totalTokens <= maxTokens, "Exceeded amount of tokens");
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

}