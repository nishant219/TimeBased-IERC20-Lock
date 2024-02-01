// // SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HelloMeta is Ownable {
    uint256 public withdrawTimestamp;  // Timestamp after which withdrawals are allowed
    bool public isPaused;  // Flag to indicate if the contract is paused

    struct UserFunds {
        mapping(address => uint256) tokenBalances; // Map token address to balance
    }

    mapping(address => UserFunds) private _userFunds; // Map user to funds

    event Deposit(address indexed user, uint256 amount, address indexed token); // Event emitted when user deposits tokens
    event Withdrawal(address indexed user, uint256 amount, address indexed token); // Event emitted when user withdraws tokens
    event WithdrawTimestampSet(uint256 timestamp); // Event emitted when owner sets the withdrawal timestamp
    event Pause(); // Event emitted when the contract is paused
    event Unpause(); // Event emitted when the contract is unpaused

    constructor(uint256 _withdrawTimestamp, address initialOwner) Ownable(initialOwner) {
        //require(_withdrawTimestamp > block.timestamp, "Withdraw timestamp must be in the future");
        withdrawTimestamp = _withdrawTimestamp;
        isPaused = false;
    }
    
    // Modifier to check if withdrawal timestamp has passed and the contract is not paused
    modifier onlyAfterWithdrawTimestampAndNotPaused() {
        require(block.timestamp >= withdrawTimestamp, "Withdrawal is not allowed yet");
        require(!isPaused, "Contract is paused");
        _;
    }


function deposit(uint256 amount, address token) external {
    require(amount > 0, "Deposit amount must be greater than 0");
    require(token != address(0), "Invalid token address");
    require(!isPaused, "Contract is paused");

    // Assuming 'token' is an instance of the ERC-20 token contract
    IERC20 tokenContract = IERC20(token);

    // Check the user's token balance
    uint256 balance = tokenContract.balanceOf(msg.sender);
    require(balance >= amount, "Insufficient token balance");

    // Check the user's allowance
    uint256 allowance = tokenContract.allowance(msg.sender, address(this));
    require(allowance >= amount, "Insufficient allowance");

    // Approve the contract to spend tokens on behalf of the user
    bool isApproved = tokenContract.approve(address(this), amount);
    require(isApproved, "Approval failed");

    // Transfer tokens from user to contract using transferFrom
    require(tokenContract.transferFrom(msg.sender, address(this), amount), "TransferFrom failed");

    // Update user funds
    _userFunds[msg.sender].tokenBalances[token] += amount; 

    emit Deposit(msg.sender, amount, token);
}



    // function deposit(uint256 amount, address token) external {
    //     require(amount > 0, "Deposit amount must be greater than 0");
    //     require(token != address(0), "Invalid token address");
    //     require(!isPaused, "Contract is paused");

    //     // Assuming 'token' is an instance of the ERC-20 token contract
    //     bool isApproved = IERC20(token).approve(address(this), amount); 
    //     require(isApproved, "Approval failed");

    //     // Transfer tokens from user to contract
    //     IERC20(token).transferFrom(msg.sender, address(this), amount); // transferFrom is from ERC20  

    //     // Update user funds
    //     _userFunds[msg.sender].tokenBalances[token] += amount; 

    //     emit Deposit(msg.sender, amount, token);
    // }




    function withdraw(uint256 amount, address token) external onlyAfterWithdrawTimestampAndNotPaused {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(_userFunds[msg.sender].tokenBalances[token] >= amount, "Insufficient user balance");

        // Transfer tokens from contract to user
        IERC20(token).transfer(msg.sender, amount);

        // Update user funds
        _userFunds[msg.sender].tokenBalances[token] -= amount;

        emit Withdrawal(msg.sender, amount, token);
    }


    function setWithdrawTimestamp(uint256 _withdrawTimestamp) external onlyOwner {
        require(_withdrawTimestamp > block.timestamp, "New timestamp must be in the future");
        withdrawTimestamp = _withdrawTimestamp;
        emit WithdrawTimestampSet(_withdrawTimestamp);
    }


    function getUserBalance(address user, address token) external view returns (uint256) {
        return _userFunds[user].tokenBalances[token];
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
