// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProposalVoting{

    address public owner;
    uint public proposalCount = 0;

    struct Proposal{
        uint id;
        string description;
        uint votesFor;
        uint votesAgainst;
        bool active;
        mapping (address => bool) hasVoted;
    }

    mapping (uint => Proposal) public proposals;

    modifier onlyOwner(){
        require(msg.sender == owner,"Only the owner can call this function.");
        _;
    }

    constructor () {
        owner = msg.sender;
    }

    function createProposal(string memory _description) public onlyOwner {
        proposalCount++;
        proposals[proposalCount].id = proposalCount;
        proposals[proposalCount].description = _description;
        proposals[proposalCount].active = true;
    }

    function vote(uint _proposalId, bool _support) public {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.active,"this proposal is no longer active.");
        require(!proposal.hasVoted[msg.sender],"You have already voted on this proposal.");

        if (_support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        proposal.hasVoted[msg.sender] = true;
    }

    function endProposal(uint _proposalId) public onlyOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.active,"The proposal is already closed.");
        proposal.active = false;
    }

    function getProposal(uint _proposalId) public view returns(
        uint id,
        string memory description,
        uint votesFor,
        uint votesAgainst,
        bool active
    ) {
        Proposal storage proposal = proposals[_proposalId];
        return(
            proposal.id,
            proposal.description,
            proposal.votesFor,
            proposal.votesAgainst,
            proposal.active
        );
    }
}