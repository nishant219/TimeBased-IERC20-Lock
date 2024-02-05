// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC20Token is ERC20Burnable, Ownable {
    constructor(string memory name_, string memory symbol_, uint256 initialSupply, address initialOwner) ERC20(name_, symbol_) Ownable(initialOwner) {
        _mint(initialOwner, initialSupply);
    }

    function approveOtherContract(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    // Override transfer function to check for positive amount
    function transfer(address to, uint256 amount) public override returns (bool) {
        require(amount > 0, "Amount must be greater than zero");
        return super.transfer(to, amount);
    }

    // Override transferFrom function to check for positive amount
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(amount > 0, "Amount must be greater than zero");
        return super.transferFrom(from, to, amount);
    }

    // For example, you might want to add a function to mint new tokens
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
}
