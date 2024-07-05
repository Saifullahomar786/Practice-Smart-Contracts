// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LandRegistry {
    
    struct Land {
        string cnic;
        string physicalAddress;
        uint256 size;
    }
    
    struct Transfer {
        string oldCNIC;
        string[] newMaleCNICs;
        string[] newFemaleCNICs;
        string newTransgenderCNIC;
        uint256 originalSize;
        uint256 maleSize;
        uint256 femaleSize;
        uint256 transgenderSize;
    }
    
    mapping(string => Land[]) private landOwnedByCNIC;
    mapping(string => Transfer[]) private landTransferHistory;
    
    event LandRegistered(string indexed cnic, string physicalAddress, uint256 size);
    event LandTransferred(string indexed oldCNIC, string[] newMaleCNICs, string[] newFemaleCNICs, string indexed newTransgenderCNIC, string physicalAddress, uint256 originalSize, uint256 maleSize, uint256 femaleSize, uint256 transgenderSize);
    
    // Register a new land
    function registerLand(string memory _cnic, string memory _physicalAddress, uint256 _size) public {
        require(bytes(_cnic).length > 0, "CNIC should not be empty");
        require(bytes(_physicalAddress).length > 0, "Physical address should not be empty");
        require(_size > 0, "Size should be greater than zero");
        
        Land memory newLand = Land(_cnic, _physicalAddress, _size);
        landOwnedByCNIC[_cnic].push(newLand);
        
        emit LandRegistered(_cnic, _physicalAddress, _size);
    }
    
    // Get all land details by CNIC
    function getLandByCNIC(string memory _cnic) public view returns (Land[] memory) {
        Land[] memory lands = landOwnedByCNIC[_cnic];
        require(lands.length > 0, "No land found for the given CNIC");
        
        // Resize the lands array to remove any empty elements
        assembly {
            mstore(lands, mload(lands))
        }
        
        return lands;
    }
    
    // Transfer land ownership to male, female, and transgender owners with dynamically allocated sizes
    function transferLand(
        string memory _oldCNIC, 
        string[] memory _newMaleCNICs, 
        string[] memory _newFemaleCNICs, 
        string memory _newTransgenderCNIC,
        string memory _physicalAddress, 
        uint256 _size
    ) public {
        require(bytes(_oldCNIC).length > 0, "Current CNIC should not be empty");
        require(_newMaleCNICs.length > 0, "At least one male owner should be provided");
        require(_newFemaleCNICs.length > 0, "At least one female owner should be provided");
        require(bytes(_newTransgenderCNIC).length > 0, "Transgender owner should be provided");
        require(bytes(_physicalAddress).length > 0, "Physical address should not be empty");
        require(_size > 0, "Size should be greater than zero");
        
        Land[] storage lands = landOwnedByCNIC[_oldCNIC];
        uint256 landIndex = findLandIndex(lands, _physicalAddress);
        
        require(landIndex != lands.length, "Land not found for the given CNIC and physical address");
        require(lands[landIndex].size >= _size, "Not enough land size to transfer");
        
        uint256 totalMaleSize = (_size * 5833) / 10000;
        uint256 totalFemaleSize = (_size * 2917) / 10000;
        uint256 totalTransgenderSize = (_size * 1250) / 10000;
        
        // Update the size of the land for the original CNIC
        lands[landIndex].size -= _size;
        
        // Update the size of the land for the male owners
        for (uint256 i = 0; i < _newMaleCNICs.length; i++) {
            landOwnedByCNIC[_newMaleCNICs[i]].push(Land(_newMaleCNICs[i], _physicalAddress, totalMaleSize / _newMaleCNICs.length));
        }
        
        // Update the size of the land for the female owners
        for (uint256 i = 0; i < _newFemaleCNICs.length; i++) {
            landOwnedByCNIC[_newFemaleCNICs[i]].push(Land(_newFemaleCNICs[i], _physicalAddress, totalFemaleSize / _newFemaleCNICs.length));
        }

        // Update the size of the land for the transgender owner
        landOwnedByCNIC[_newTransgenderCNIC].push(Land(_newTransgenderCNIC, _physicalAddress, totalTransgenderSize));

        emit LandTransferred(_oldCNIC, _newMaleCNICs, _newFemaleCNICs, _newTransgenderCNIC, _physicalAddress, lands[landIndex].size + _size, totalMaleSize, totalFemaleSize, totalTransgenderSize);
        
        // Add transfer details to history
        landTransferHistory[_physicalAddress].push(Transfer({
            oldCNIC: _oldCNIC,
            newMaleCNICs: _newMaleCNICs,
            newFemaleCNICs: _newFemaleCNICs,
            newTransgenderCNIC: _newTransgenderCNIC,
            originalSize: lands[landIndex].size + _size,
            maleSize: totalMaleSize,
            femaleSize: totalFemaleSize,
            transgenderSize: totalTransgenderSize
        }));
        
        // Check if the original CNIC has any remaining lands
        if (lands[landIndex].size == 0) {
            removeLandAtIndex(lands, landIndex);
        }
    }
    
    // Get land transfer history by physical address
    function getLandHistoryByPhysicalAddress(string memory _physicalAddress) public view returns (Transfer[] memory) {
        return landTransferHistory[_physicalAddress];
    }

    // Internal function to find the index of a land in the lands array based on the physical address
    function findLandIndex(Land[] storage lands, string memory _physicalAddress) internal view returns (uint256) {
        for (uint i = 0; i < lands.length; i++) {
            if (keccak256(bytes(lands[i].physicalAddress)) == keccak256(bytes(_physicalAddress))) {
                return i;
            }
        }
        return lands.length;
    }
    
    // Internal function to remove a land from the lands array at a specific index
    function removeLandAtIndex(Land[] storage lands, uint256 index) internal {
        if (index < lands.length) {
            for (uint i = index; i < lands.length - 1; i++) {
                lands[i] = lands[i + 1];
            }
            lands.pop();
        }
    }
}
