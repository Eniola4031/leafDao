
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/*
* only those with lazylion token can mint
* 
*/
contract leafDao is Ownable {

    uint256 mintPrice = 0.06 ether;
    ERC721 public lazyLionToken;
    bool public enableWhitelist = false;
    //address holder;



    constructor(address lionToken) {
        lazyLionToken = ERC721(lionToken) ;

    }
        mapping(address => address) holderToWhitelist;

    // function mintLion(uint256 numberOfTokens) public payable {
    //     require(saleIsActive, "Sale must be active to mint Lion");
    //     require(
    //         numberOfTokens > 0 && numberOfTokens <= maxLionPurchase,
    //         "Can only mint 3 tokens per wallet"
    //     );
    //     require(
    //         totalSupply().add(numberOfTokens) <= MAX_LIONS,
    //         "Purchase would exceed max supply of Lions"
    //     );
    //     require(
    //         msg.value >= lionPrice(numberOfTokens++)),
    //         "Ether value sent is not correct"
    //     );
    // }

    
    function addToWhitelist(address user) public onlyOwner{
        //require(msg.sender == user);
        holderToWhitelist[msg.sender] = user;

    }

    function isWhitelist(address whitelisted) public returns(bool){
        holderToWhitelist[whitelisted];
        return true;
    }

    function whitelistState() public onlyOwner{
        enableWhitelist =!enableWhitelist;

    }

   
   
}