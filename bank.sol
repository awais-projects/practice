// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank{

    uint public balance;   //stores total  balance in the contract

    //deposit function for depositing ether
    function deposit() public payable {
        balance += msg.value;    //increase balance by the amount sent
    }

    // withdraw function to withdraw a specific amount
    function withdraw(uint amount) public {
        require(amount <= balance, "Issuficient balance");
        balance -= amount;
        payable(msg.sender).transfer(amount);
    }

    // Getter function to view the total balance in the contract
    function getBalance() public view returns (uint) {
        return balance;
    }
}

