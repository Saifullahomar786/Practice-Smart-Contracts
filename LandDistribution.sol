// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LandDistribution {
    address public owner;
    uint256 public totalLand;
    mapping(address => uint256) public landOwnership;

    struct Parent {
        string name;
        string CNIC;
        bool isAlive;
    }

    struct Child {
        string name;
        string gender;
        uint256 providedLand;
        string cnic;
    }

    Parent public father;
    Parent public spouse;
    Child[] public children;

    event LandDistributed(address indexed recipient, uint256 amount);

    constructor(uint256 _totalLand) {
        owner = msg.sender;
        totalLand = _totalLand;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function distributeLand(
        uint256 totalChildren,
        uint256 totalMaleChildren,
        uint256 totalFemaleChildren
    ) external onlyOwner {
        require(totalChildren > 0, "Total children should be greater than 0");
        require(
            totalMaleChildren + totalFemaleChildren == totalChildren,
            "Total male and female children should match total children"
        );

        uint256 landPerChild = totalLand / totalChildren;
        uint256 landToDistribute;

        // Distribute land to male children
        landToDistribute = landPerChild * totalMaleChildren;
        for (uint256 i = 0; i < totalMaleChildren; i++) {
            address maleChild =
                address(uint160(uint256(keccak256(abi.encodePacked(msg.sender, i)))));
            landOwnership[maleChild] += landToDistribute;
            emit LandDistributed(maleChild, landToDistribute);
        }

        // Distribute land to female children
        landToDistribute = landPerChild * totalFemaleChildren;
        for (uint256 i = 0; i < totalFemaleChildren; i++) {
            address femaleChild =
                address(uint160(uint256(keccak256(abi.encodePacked(msg.sender, totalMaleChildren + i)))));
            landOwnership[femaleChild] += landToDistribute;
            emit LandDistributed(femaleChild, landToDistribute);
        }
    }

    function updateFamilyInfo(
        uint256 _totalLand,
        string memory _fatherName,
        string memory _fatherCNIC,
        bool _fatherIsAlive,
        string memory _spouseName,
        string memory _spouseCNIC,
        bool _spouseIsAlive,
        uint256 _spouseProvidedLand,
        Child[] memory _children
    ) external onlyOwner {
        totalLand = _totalLand;

        father = Parent(_fatherName, _fatherCNIC, _fatherIsAlive);

        if (_spouseIsAlive) {
            spouse = Parent(_spouseName, _spouseCNIC, true);
            totalLand -= _spouseProvidedLand;
        } else {
            delete spouse;
        }

        delete children;
        for (uint256 i = 0; i < _children.length; i++) {
            children.push(_children[i]);
            totalLand -= _children[i].providedLand;
        }
    }
}
