// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting{

    // struct to store the data of the candidate

    struct Candidate{
        uint id;
        string name;
        address candidateAddress;
        uint voteCount;
        uint age;
    }

    // struct to store the voter data

    struct Voter{
        bool isVoted;
        uint age;
    } 

    //variables for counter of candidates and votes
    uint public candidateCount;
    uint public voteCounter;

    // mapping for storing candidates and voters
    mapping (uint => Candidate) public candidates;
    mapping (address => Voter) internal voters;

    //events for transparency in logs
    //{
    event CandidateRegistered(uint indexed candidateId, string name, address candidateAddress);
    event VoteCast(address indexed voter, uint indexed candidateId);
    //}

    //function to register a new candidate
    function registerCandidate(string memory _name, uint _age) public {
        require(_age>= 21 && _age <= 60,"Age must be between 21 to 60 to be eligible");

        candidateCount++;
        candidates[candidateCount] = Candidate(candidateCount, _name, msg.sender, 0 , _age);

        //{
        emit CandidateRegistered(candidateCount, _name, msg.sender);
        //}
    }

    //function for vote casting
    function castVote(uint _candidateId) public  {
        require(voters[msg.sender].isVoted == false,"You have already voted");
        require(voters[msg.sender].age >= 18,"Age must be 18 years to vote");
        
        voteCounter++;
        voters[msg.sender].isVoted = true;
        candidates[_candidateId].voteCount++;

        //{
            emit VoteCast(msg.sender, _candidateId);
            //}
    }

    // function to register a voter with age
    function registerVoter(uint _age) public {
        require( _age >= 18, "Minimum age for voting is 18");
        require( voters[msg.sender].age == 0, "Voter is already registered");
        voters[msg.sender] = Voter(false,_age);
    }

    // get a candidate's details by id
    function getCandidate(uint _candidateId) public view returns (string memory, address, uint) {
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.name, candidate.candidateAddress, candidate.voteCount);
    }

    // check if an address has voted
    function hasVoted(address _voter) public view returns (bool) {
        Voter memory voted = voters[_voter];
        return (voted.isVoted);

    }

    // get total votes cast
    function totalVotes() public view returns(uint){
        return voteCounter;
    }


}
