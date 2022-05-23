// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minimum) public {
        address newCampaign=address(new Campaign(minimum,msg.sender));
        deployedCampaigns.push(newCampaign);
    }
    function getDeployedCampaigns() public view returns (address[] memory){
        return deployedCampaigns;
    }
}
contract Campaign {

    struct Request{
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address=>bool) approvals;
        
    }

    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    mapping(address=>bool) public approvers;
    uint public approversCount;

    modifier restricted(){
        require(msg.sender==manager);
        _;
    }

    constructor(uint minimum,address creator){
        manager=creator;
        minimumContribution=minimum;
        approversCount=0;
    }

    function contribute () public payable {
        require(msg.value>minimumContribution);
        require(!approvers[msg.sender]);
        approvers[msg.sender]=true;
        approversCount++;
    }


    function createRequest (string memory description,uint value,address recipient) public restricted {
        Request storage r=requests.push();
            r.description=description;
            r.value=value;
            r.recipient=recipient;
            r.complete=false;
            r.approvalCount=0;
    }

    function approveRequests (uint index) public {
        require(approvers[msg.sender]);
        require(!requests[index].approvals[msg.sender]);
        requests[index].approvals[msg.sender]=true;
        requests[index].approvalCount++;
    }

    function finalizeRequest(uint index) public payable restricted {
        Request storage request=requests[index];
        require(request.approvalCount > approversCount/2);
        require(!request.complete);
        payable(request.recipient).transfer(request.value);
        request.complete=true;

    }
}
