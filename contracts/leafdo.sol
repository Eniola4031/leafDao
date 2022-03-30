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
    string public constant whitelistRole ="whitelist";
    string public constant adminRole = "admin";
    bool public enableWhitelist = false;
    bool public disableWhitelist = false;
    uint mintLazyEditionAmt = 1;



                //checks if address if whitelisted
             mapping(address => bool) public whitelisted;
             mapping(address => bool) public admin;
            mapping (address => uint) public balances;


    
/**
   * @dev Throws if called by any account that's not eded.
   */
         modifier onlyIfWhitelisted(address _operator) {
    require(whitelisted[_operator]);
    _;
  }
   modifier onlyAdmin(){
         //  require(msg.sender == owner);

    require(admin[msg.sender]);  
      _;
   }
   

    
  
      event WhitelistedAddressAdded(address addr);
      //event WhitelistedAddressRemoved(address addr);


  /**
   * @dev add an address to the whitelist
   * @param addr address
   * @notice true if the address was added to the whitelist, false if the address was already in the whitelist 
   */
  function addToWhitelist(address addr) onlyOwner public returns(bool success) {
    //   require(whitelist[addr] == true);
    //   require(WhitelistedAddressAdded(addr) == true);      
    if (!whitelisted[addr]) {
      whitelisted[addr] = true;

        emit WhitelistedAddressAdded(addr);
      success = true; 
    }

  }
  function addAsAdmin(address addr) onlyOwner external returns(bool success) {
    //    require(!admin[addr], "already an admin");
    //    admin[addr];
    if (!admin[addr]) {
      admin[addr] = true;
      success = true; 
    }
  }

  /**
   * @dev add addresses to the whitelist
   * @param addrs addresses
   * @notice true if at least one address was added to the whitelist, 
   * false if all addresses were already in the whitelist  
   */
  function addAddressesToWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (addToWhitelist(addrs[i])) {
        success = true;
      }
    }
  }



    
   function increaseMintAmt() onlyAdmin public {
       require(admin[msg.sender],"the method can only be called by the admin");
         mintLazyEditionAmt++;

   }

   function mintLazyEdition(address addr, uint tokenamt) onlyIfWhitelisted(addr) public {
       //mintLazyEditionAmt= tokenamt;
       require(tokenamt == mintLazyEditionAmt,"You can only mint 1 token per wallet");
       require(whitelisted[addr],"you are not whitelisted");
       balances[msg.sender] += tokenamt;

   }
              //error InsufficientBalance(uint requested, uint available);

      function mintKingEdition(address addr, uint tokenamt) onlyIfWhitelisted(addr) public payable{
       uint mintKingEditionAmt= 3;
       require(tokenamt == mintKingEditionAmt,"You can only mint 3 token per wallet");
       require(whitelisted[addr],"you are not whitelisted");
       balances[msg.sender] += tokenamt;


   }


   function whitelistState(bool _state) public onlyAdmin{
       enableWhitelist = _state;

   }

  //   /**
//    * @dev remove an address from the whitelist
//    * @param addr address
//    * @return true if the address was removed from the whitelist, 
//    * false if the address wasn't in the whitelist in the first place 
//    */
//   function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
//     if (whitelist[addr]) {
//       whitelist[addr] = false;
//       WhitelistedAddressRemoved(addr);
//       success = true;
//     }
//   }

//   /**
//    * @dev remove addresses from the whitelist
//    * @param addrs addresses
//    * @return true if at least one address was removed from the whitelist, 
//    * false if all addresses weren't in the whitelist in the first place
//    */
//   function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {
//     for (uint256 i = 0; i < addrs.length; i++) {
//       if (removeAddressFromWhitelist(addrs[i])) {
//         success = true;
//       }
//     }
//   } 
}