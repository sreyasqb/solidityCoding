// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract Election{

    struct Candidate{
        // address candidate;
        string name;
        string party;
        uint removeCount;
        bool removed;
        mapping(address=>bool) removers;
        uint voteCount;
    }

    address public electionCommissioner;
    uint minimumCost;
    mapping(address=>Candidate) candidates;
    address[] candidateAddresses;
    uint public candidatesCount;
    uint maxCandidates=3;
    mapping(address=>bool) voters;
    uint population=4;
    bool electionsStarted;

    modifier commissioner(){
        require(msg.sender==electionCommissioner);
        _;
    }
    modifier notCommissioner(){
        require(msg.sender!=electionCommissioner);
        _;
    }
    modifier allowEntry(string memory name,string memory party){
        require(bytes(name).length!=0 && bytes(party).length!=0);
        require(candidatesCount<=maxCandidates);
        require (bytes(candidates[msg.sender].name).length==0 && bytes(candidates[msg.sender].name).length==0 && !candidates[msg.sender].removed);
        
        _;
    }
    modifier electionsModifier(){
        require(!electionsStarted);
        _;
    }
    modifier allowVoting(){
        require(!voters[msg.sender]);
        _;
    }
    

    constructor(uint value){
        electionCommissioner=msg.sender;
        minimumCost=value;
    }

    function addCandidate(string memory name,string memory party) public payable notCommissioner electionsModifier allowEntry(name,party) {
        require(msg.value>minimumCost);
        candidateAddresses.push(msg.sender);
        Candidate storage candidate=candidates[msg.sender];
        candidate.name=name;
        candidate.party=party;
        candidate.removeCount=0;
        candidate.voteCount=0;
        candidate.removed=false;
        candidatesCount+=1;        
    }
    function getCandidateDetails(address c) public view returns (string memory,string memory){
        return (candidates[c].name,candidates[c].party);
    }

    function getAllCandidates() public view returns (address[] memory){
        return candidateAddresses;
    }

    function removeCandidates(address c) public electionsModifier{
        require(!candidates[c].removers[msg.sender]);
        if (candidates[c].removeCount >= population/2){
            candidates[c].removed=true;
            //LOGIC TO REMOVE AN ELEMENT
            uint index=0;
            for (uint i=0;i<candidatesCount;i++){
                if (candidateAddresses[i]==c){
                    index=i;
                    break;
                }
            }
            candidateAddresses[index]=candidateAddresses[candidatesCount-1];
            candidateAddresses.pop();
            candidatesCount-=1;

        }
        else {
            candidates[c].removeCount+=1;
            candidates[c].removers[msg.sender]=true;
        }
    }
    function startElections() public  commissioner electionsModifier {
        electionsStarted=true;
    }
    function voteCandidate(address candidate) public allowVoting {
        require(electionsStarted);
        voters[msg.sender]=true;
        candidates[candidate].voteCount+=1;
    }


}
