// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public manager;  // The manager of the lottery
    address[] public players;  // Array to store the addresses of participants
    mapping(address => bool) public hasEntered; // Mapping to track if an address has entered

    constructor() {
        manager = msg.sender;  // The creator of the contract is the manager
    }

    // Function for entering the lottery
    function enter() public payable {
        require(msg.value >= 0.02 ether, "Minimum contribution is 0.01 ether");
        require(!hasEntered[msg.sender], "You have already entered the lottery");
        
        players.push(msg.sender);  // Add the sender's address to the list of players
        hasEntered[msg.sender] = true; // Mark the address as entered
    }

    // Generate a pseudo-random number using block data
    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
    }

    // Function for picking a winner
    function pickWinner() public restricted {
        require(players.length > 0, "No participants in the lottery");
        
        uint index = random() % players.length;
        address winner = players[index];
        payable(winner).transfer(address(this).balance);  // Convert to address payable and transfer the balance to the winner
        players = new address[](0);  // Reset the list of players
    }

    // Function for the manager to withdraw contract balance
    function withdrawBalance() public restricted {
        payable(manager).transfer(address(this).balance);
    }

    // Function to get the list of players
    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    // Modifier to restrict access to the manager
    modifier restricted() {
        require(msg.sender == manager, "Only the manager can call this function");
        _;
    }
}
