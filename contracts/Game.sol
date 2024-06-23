pragma solidity ^0.8.0;

contract Game {
    struct Balance {
        uint256 amount;
        address token;
    }

    mapping(address => mapping(address => uint256)) public balances;

    function deposit(address token, uint256 amount) public {
        balances[msg.sender][token] += amount;
    }

    function withdraw(address token, uint256 amount) public {
        require(balances[msg.sender][token] >= amount, "Insufficient balance");
        balances[msg.sender][token] -= amount;
        // transfer logic here
    }

    function getBalance(address user, address token) public view returns (uint256) {
        return balances[user][token];
    }
}
