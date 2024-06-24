// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Game is Ownable {
    struct Balance {
        uint256 amount;
        address token;
    }

    struct WithdrawalRequest {
        address token;
        uint256 amount;
        uint256 timestamp;
    }

    uint256 public withdrawalTimeout = 360 seconds;
    mapping(address => mapping(address => uint256)) public balances;
    mapping(address => WithdrawalRequest[]) public withdrawalRequests;

    event Deposit(address indexed user, address indexed token, uint256 amount);
    event WithdrawalRequested(address indexed user, address indexed token, uint256 amount);
    event WithdrawalCompleted(address indexed user, address indexed token, uint256 amount);

    modifier hasEnoughBalance(address user, address token, uint256 amount) {
        require(balances[user][token] >= amount, "Insufficient balance");
        _;
    }

    function setWithdrawalTimeout(uint256 _timeout) external onlyOwner {
        withdrawalTimeout = _timeout;
    }

    function deposit(address token, uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        balances[msg.sender][token] += amount;

        emit Deposit(msg.sender, token, amount);
    }

    function requestWithdrawal(address token, uint256 amount)
        external
        hasEnoughBalance(msg.sender, token, amount)
    {
        withdrawalRequests[msg.sender].push(WithdrawalRequest({
            token: token,
            amount: amount,
            timestamp: block.timestamp
        }));

        emit WithdrawalRequested(msg.sender, token, amount);
    }

    function executeWithdrawal(uint256 requestIndex) external {
        WithdrawalRequest memory request = withdrawalRequests[msg.sender][requestIndex];
        require(block.timestamp >= request.timestamp + withdrawalTimeout, "Withdrawal timeout not reached");

        balances[msg.sender][request.token] -= request.amount;
        IERC20(request.token).transfer(msg.sender, request.amount);

        // Remove the withdrawal request from the array
        for (uint256 i = requestIndex; i < withdrawalRequests[msg.sender].length - 1; i++) {
            withdrawalRequests[msg.sender][i] = withdrawalRequests[msg.sender][i + 1];
        }
        withdrawalRequests[msg.sender].pop();

        emit WithdrawalCompleted(msg.sender, request.token, request.amount);
    }

    function getBalance(address user, address token) external view returns (uint256) {
        return balances[user][token];
    }

    function getWithdrawalRequests(address user) external view returns (WithdrawalRequest[] memory) {
        return withdrawalRequests[user];
    }

    receive() external payable {
        revert("Direct deposits not allowed");
    }
}
