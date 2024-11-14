// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdFunding{

    address public owner;
    uint public campaignsCount;

    struct Campaign{
        address creator;
        string name;
        string description;
        uint goal;
        uint fundsRaised;
        uint deadline;
        bool goalReached;
        bool closed;
    }

    mapping (uint => Campaign) public campaigns;
    mapping (uint => mapping (address => uint)) public contributions;

    modifier onlyOwner (){
        require(msg.sender == owner,"Only the owner can call this function");
        _;
    }

    modifier onlyCreator (uint _campaignId){
        require(msg.sender == campaigns[_campaignId].creator,"Only the owner can call this function");
        _;
    }

    constructor(){
        owner = msg.sender;
    }

    function createCampaign(string memory _name, string memory _description, uint _goal, uint _deadline) public {
        require(_goal > 0,"Goal must be greator than 0.");
        campaignsCount++;
        campaigns[campaignsCount] = Campaign ({
            creator: msg.sender,
            name: _name,
            description: _description,
            goal: _goal,
            fundsRaised : 0,
            deadline: block.timestamp + _deadline,
            goalReached: false,
            closed: false
        });
    }

    function donate(uint _campaignId) public payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline,"Time out" );
        require(!campaign.goalReached,"Goal is already reached.");
        require(!campaign.closed,"Campaign closed");

        campaign.fundsRaised += msg.value;

        if (campaign.fundsRaised >= campaign.goal){
            campaign.goalReached = true; 
        }
    }

    function withdrawFund(uint _campaignId) public onlyCreator(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        require(campaign.goalReached,"Didn't meet the goal");
        require(block.timestamp > campaign.deadline,"Campaign is still live.");
        require(!campaign.closed,"Campaign is already closed");

        payable(campaign.creator).transfer(campaign.fundsRaised);
        campaign.closed = true;
    }

    function refund(uint _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];

        require(!campaign.goalReached,"Campaign goal is reached");
        require(block.timestamp >= campaign.deadline,"Campaign is still live");
        require(contributions[_campaignId][msg.sender] > 0,"No contribution is found");
        uint amount = contributions[_campaignId][msg.sender];
        contributions[_campaignId][msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function getCampaign(uint _campaignId) public view returns(address, string memory,string memory, uint, uint, uint, bool, bool){
        Campaign storage campaign = campaigns[_campaignId];
        return (campaign.creator,campaign.name,campaign.description,campaign.goal,campaign.fundsRaised,campaign.deadline,campaign.goalReached,campaign.closed);
    }



}