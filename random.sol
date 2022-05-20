// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;
contract Inbox{
    address public manager;
    address[] public players;
    constructor () {
        manager=msg.sender;
    }
    function addPlayer() public payable {
        require(msg.value>0.1 ether);
        players.push(msg.sender);
    }
    function getPlayers() public view returns(address[] memory){
        return players;
    }
    function random() private view returns (uint){
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,players)));
    }
    function getWinner() public payable {
        uint index=random()%players.length;
        payable(players[index]).transfer(address(this).balance);
        players = new address[](0);
    }
    
}
