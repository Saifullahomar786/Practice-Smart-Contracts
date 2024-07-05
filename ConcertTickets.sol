// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TokenMaster is ERC721 {
    address public owner;
    uint256 public totalConcerts;
    uint256 public totalTicketsSold;

    struct Concert {
        string name;
        uint256 cost;
        uint256 maxTickets;
        uint256 ticketsSold;
        string date;
        string time;
        string location;
        mapping(uint256 => address) seatTaken;
        mapping(address => bool) hasBought;
    }

    Concert[] public concerts;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        owner = msg.sender;
    }

    function list(
        string memory _name,
        uint256 _cost,
        uint256 _maxTickets,
        string memory _date,
        string memory _time,
        string memory _location
    ) public onlyOwner {
        concerts.push(Concert({
            name: _name,
            cost: _cost,
            maxTickets: _maxTickets,
            ticketsSold: 0,
            date: _date,
            time: _time,
            location: _location
        }));
        totalConcerts++;
    }

    function mint(uint256 _id, uint256 _seat) public payable {
        require(_id < concerts.length, "Invalid concert ID");
        Concert storage concert = concerts[_id];

        require(msg.value >= concert.cost, "Insufficient payment");
        require(concert.ticketsSold < concert.maxTickets, "All tickets sold out");
        require(!concert.hasBought[msg.sender], "You have already bought a ticket");
        require(_seat < concert.maxTickets, "Invalid seat number");
        require(concert.seatTaken[_seat] == address(0), "Seat already taken");

        concert.seatTaken[_seat] = msg.sender;
        concert.hasBought[msg.sender] = true;
        concert.ticketsSold++;
        totalTicketsSold++;

        _safeMint(msg.sender, totalTicketsSold);
    }

    function getConcert(uint256 _id) public view returns (
        string memory name,
        uint256 cost,
        uint256 maxTickets,
        uint256 ticketsSold,
        string memory date,
        string memory time,
        string memory location
    ) {
        require(_id < concerts.length, "Invalid concert ID");
        Concert storage concert = concerts[_id];
        return (
            concert.name,
            concert.cost,
            concert.maxTickets,
            concert.ticketsSold,
            concert.date,
            concert.time,
            concert.location
        );
    }

    function getSeatsTaken(uint256 _id) public view returns (address[] memory) {
        require(_id < concerts.length, "Invalid concert ID");
        Concert storage concert = concerts[_id];
        address[] memory takenSeats = new address[](concert.maxTickets);
        for (uint256 i = 0; i < concert.maxTickets; i++) {
            takenSeats[i] = concert.seatTaken[i];
        }
        return takenSeats;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Contract balance is zero");
        (bool success, ) = owner.call{value: balance}("");
        require(success, "Withdrawal failed");
    }
}
