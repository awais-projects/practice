// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionContract{

    address public owner;
    uint public subscriptionFee;
    uint public subscriptionDuration;

    struct Subscriber{
        uint expirationTime;
    }

    mapping (address => Subscriber) public subscribers;

    constructor (){
        owner = msg.sender;
    }

    modifier OnlyOwner() {
        require (msg.sender == owner,"You are not the owner");
        _;
    }

    function subscribe() public payable {
        require (msg.value == subscriptionFee,"Please select the correct amount.");

    
        if(subscribers[msg.sender].expirationTime > block.timestamp){
            subscribers[msg.sender].expirationTime += subscriptionDuration;
        }else{
            subscribers[msg.sender].expirationTime = block.timestamp + subscriptionDuration;
        }
    }

    function isSubscribed(address _user) public view returns (bool) {
        return subscribers[_user].expirationTime > block.timestamp;
    }

    function unSubscribe() public {
        require(isSubscribed(msg.sender),"You are not the subscriber.");
        uint remainingTime = (subscribers[msg.sender].expirationTime) - block.timestamp;
        uint refundAmount = (remainingTime * subscriptionFee) / subscriptionDuration;
        subscribers[msg.sender].expirationTime = block.timestamp;

        payable(msg.sender).transfer(refundAmount);
    }
        function withdrawFunds() public OnlyOwner {
        payable(owner).transfer(address(this).balance);

    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

}