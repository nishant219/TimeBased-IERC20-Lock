// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TimeLockedWallet is Ownable {
    using SafeERC20 for IERC20;
    bool public isPaused;  // Flag to indicate if the contract is paused
    uint256 public withdrawTimestamp;  // Timestamp after which withdrawals are allowed

    // Struct to store user funds
    struct UserFunds {
        uint256 totalBalance;
        mapping(address => uint256) tokenBalances; 
        uint256 unlockTimestamp;
    }

    mapping(address => UserFunds) public userFunds; // Map user to funds

    event Deposit(address indexed user, address indexed token, uint256 amount); // Event emitted when user deposits tokens
    event Withdraw(address indexed user, address indexed token, uint256 amount); // Event emitted when user withdraws tokens
    event Pause(); // Event emitted when the contract is paused
    event Unpause(); // Event emitted when the contract is unpaused
    event WithdrawTimestampSet(uint256 timestamp); // Event emitted when owner sets the withdrawal timestamp


    // Modifier to check if withdrawal timestamp has passed and the contract is not paused
    modifier onlyAfterWithdrawTimestampAndNotPaused() {
        require(block.timestamp >= withdrawTimestamp, "Withdrawal is not allowed yet");
        require(!isPaused, "Contract is paused");
        _;
    }

    constructor(uint256 _withdrawTimestamp, address initialOwner) Ownable(initialOwner) {
        require(_withdrawTimestamp > block.timestamp, "Withdraw timestamp must be in the future");
        withdrawTimestamp = _withdrawTimestamp;
        isPaused = false;
    }

    function deposit(address token, uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");
        require(!isPaused, "Contract is paused");
        
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount); // Transfer tokens from user to contract using safeTransferFrom

        userFunds[msg.sender].totalBalance += amount; // Update user's total balance
        userFunds[msg.sender].tokenBalances[token] += amount; // Update user's token balance

        emit Deposit(msg.sender, token, amount); 
    }


    // Function to withdraw tokens from the contract. Can only be called by the user.
    function withdraw(uint256 amount, address token) external onlyAfterWithdrawTimestampAndNotPaused {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(amount <= userFunds[msg.sender].tokenBalances[token], "Insufficient funds");
        require(!isPaused, "Contract is paused");

        IERC20(token).safeTransfer(msg.sender, amount);

        userFunds[msg.sender].totalBalance -= amount;
        userFunds[msg.sender].tokenBalances[token] -= amount;

        emit Withdraw(msg.sender, token, amount);
    }

    // Function to update the withdrawal timestamp. Can only be called by the owner.
    function setWithdrawTimestamp(uint256 _withdrawTimestamp) external onlyOwner {
        require(_withdrawTimestamp > block.timestamp, "New timestamp must be in the future");
        require(!isPaused, "Contract is paused");
        withdrawTimestamp = _withdrawTimestamp;
        emit WithdrawTimestampSet(_withdrawTimestamp);
    }

    // Function for deployer to check total funds in the contract
    function getTotalFunds() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }


    // For example, a function to get the total balance of a user
    function getTotalBalance(address user) external view returns (uint256) {
        return userFunds[user].totalBalance;
    }

    // A function to get the balance of a specific token for a user
    function getTokenBalance(address user, address token) external view returns (uint256) {
        return userFunds[user].tokenBalances[token];
    }

    // Pause the contract. Can only be called by the owner.
    function pause() external onlyOwner {
        //check if already paused
        require(!isPaused, "Contract is already paused");
        isPaused = true;
        emit Pause();
    }

    // Unpause the contract. Can only be called by the owner.
    function unpause() external onlyOwner {
        //check if already unpaused
        require(isPaused, "Contract is not paused");
        isPaused = false;
        emit Unpause();
    }
}
