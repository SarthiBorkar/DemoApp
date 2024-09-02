// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleDAO {
    struct Proposal {
        string description;
        uint256 voteCount;
        bool executed;
        mapping(address => bool) voted;
    }

    address public owner;
    mapping(address => bool) public members;
    Proposal[] public proposals;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender], "Not a DAO member");
        _;
    }

    event ProposalCreated(uint256 proposalId, string description);
    event Voted(uint256 proposalId, address voter);
    event ProposalExecuted(uint256 proposalId);

    constructor() {
        owner = msg.sender;
        members[msg.sender] = true;
    }

    function addMember(address member) public onlyOwner {
        members[member] = true;
    }

    function removeMember(address member) public onlyOwner {
        members[member] = false;
    }

    function createProposal(string memory description) public onlyMember {
        Proposal storage newProposal = proposals.push();
        newProposal.description = description;
        newProposal.voteCount = 0;
        newProposal.executed = false;

        emit ProposalCreated(proposals.length - 1, description);
    }

    function vote(uint256 proposalId) public onlyMember {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.voted[msg.sender], "Already voted");
        require(!proposal.executed, "Proposal already executed");

        proposal.voted[msg.sender] = true;
        proposal.voteCount++;

        emit Voted(proposalId, msg.sender);
    }

    function executeProposal(uint256 proposalId) public onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.voteCount > 0, "Not enough votes");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;

        // Proposal execution logic here (e.g., transferring funds, calling other contracts)

        emit ProposalExecuted(proposalId);
    }

    function getProposal(uint256 proposalId) public view returns (string memory description, uint256 voteCount, bool executed) {
        Proposal storage proposal = proposals[proposalId];
        return (proposal.description, proposal.voteCount, proposal.executed);
    }
}
