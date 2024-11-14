// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleAuction{
    address public owner;
    uint public auctionEndTime;
    address public highestBidder;
    uint public highestBid;

    mapping (address => uint) public pendingReturns;
    bool public ended;

    event HighestBidIncreased (address bidder, uint amount);
    event AuctionEnded (address winner, uint amount);

    constructor (uint _auctionEndTime) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + _auctionEndTime;
    }

    function bid() public payable {
        require (auctionEndTime > block.timestamp,"Time Out.");
        require (msg.value > 0,"the amount must be greater than 0.");
        require (msg.value > highestBid,"there is already a highest bidder.");
        pendingReturns[highestBidder] = highestBid;
        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    function withdraw() public returns(bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            if(!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function endAuction() public {
        require(block.timestamp > auctionEndTime,"auction already ended");
        require(msg.sender == owner,"You are not the owner.");
        require(!ended,"Auction end already call.");
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        payable(owner).transfer(highestBid);
    }
}