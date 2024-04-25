// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract MyNFT is ERC721URIStorage,Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenids ; 

    constructor() ERC721("SAIFULLAH", "SAIF") {}

    function mintNFT (address recipient ,string memory tokenURI) public onlyOwner  returns(uint256){

        _tokenids.increment();
        uint newitemid = _tokenids.current();
        _mint(recipient,newitemid);
        _setTokenURI(newitemid,tokenURI);
        return newitemid;
    }
}
