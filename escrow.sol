// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    address public buyer;
    address public seller;
    address public arbiter; // third party who can resolve disputes
    uint public amount;

    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, REFUNDED }
    State public currentState;

    constructor(address _buyer, address _seller, address _arbiter, uint _amount) {
        buyer = _buyer;
        seller = _seller;
        arbiter = _arbiter;
        amount = _amount;
        currentState = State.AWAITING_PAYMENT;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only the buyer can call this function.");
        _;
    }

    modifier onlyArbiter() {
        require(msg.sender == arbiter, "Only the arbiter can call this function.");
        _;
    }

    // Buyer deposits Ether into escrow
    function deposit() external payable onlyBuyer {
        require(currentState == State.AWAITING_PAYMENT, "Already paid.");
        require(msg.value == amount, "Must send the exact amount.");
        currentState = State.AWAITING_DELIVERY;
    }

    // Buyer confirms delivery, releasing funds to seller
    function confirmDelivery() external onlyBuyer {
        require(currentState == State.AWAITING_DELIVERY, "Cannot confirm delivery.");
        payable(seller).transfer(address(this).balance);
        currentState = State.COMPLETE;
    }

    // Arbiter refunds the buyer in case of a dispute
    function refundBuyer() external onlyArbiter {
        require(currentState == State.AWAITING_DELIVERY, "Cannot refund at this stage.");
        payable(buyer).transfer(address(this).balance);
        currentState = State.REFUNDED;
    }

    // Function to get the escrow balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
