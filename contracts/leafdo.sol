// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

 interface lazyLionI{
    function balanceOf(address owner) external view returns (uint256 balance);
 }

/*
* only those with lazylion token can mint
* 
*/
contract leafDao is ERC721, Ownable {
 using Counters for Counters.Counter;

 Counters.Counter private _tokenIds;

    uint256 mintPrice = 0.06 ether;
    string public constant whitelistRole ="whitelist";
    string public constant adminRole = "admin";
    bool public enableWhitelist = false;
    uint mintAmt;
    uint maxMintKingAmount = 3;
    uint maxMintLazyAmount = 1;
     uint lazyMaxSupply = 120;
     uint kingMaxSupply = 380;

    lazyLionI _lazyLion = lazyLionI(0x8943C7bAC1914C9A7ABa750Bf2B6B09Fd21037E0);



                //checks if address if whitelisted
             mapping(address => bool) public whitelisted;
             mapping(address => bool) public admin;
            mapping (address => uint) public balances;

    constructor()ERC721("leafDAO","LFD"){
     // _mint(msg.sender,500);

}
    
/**
   * @dev Throws if called by any account that's not eded.
   */
         modifier onlyIfWhitelisted(address _operator) {
    require(whitelisted[_operator]);
    _;
  }
   modifier onlyAdmin(){

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
  function addToWhitelist(address addr) onlyAdmin public returns(bool success) {
    //require(_lazyLion.balanceOf(addr) > 0, "not a lazy lion owner");     
    if (!whitelisted[addr]) {
      whitelisted[addr] = true;

        emit WhitelistedAddressAdded(addr);
      success = true; 
    }

  }
  function addAsAdmin(address addr) onlyOwner external returns(bool success) {
    // require(!admin[addr], "already an admin");
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
        //require(_lazyLion.balanceOf(addrs) > 0, "not a lazy lion owner");     
    for (uint256 i = 0; i < addrs.length; i++) {
      if (addToWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

       function changeMintAmt(uint256 newMint) public onlyAdmin {
        mintAmt = newMint;
    }

   function mintLazyEdition(address addr, uint tokenamt) onlyIfWhitelisted(addr) public payable{
         require(_lazyLion.balanceOf(addr) > 0, "not a lazy lion owner");     
          mintAmt = tokenamt;
         require(tokenamt > 0, "need to mint at least 1 NFT");
       require(tokenamt == 1 || tokenamt == mintAmt,"You have exceeded the max token limit per wallet");
       require(whitelisted[addr],"only whitelisted addresses can call this function");
        require(tokenamt == maxMintLazyAmount);
        require( totalSupply() + tokenamt <= lazyMaxSupply); 
        if ( totalSupply() >= 120) {
                require(msg.value >= mintAmt * tokenamt);
            } 
        if (_tokenIds.current()==0){
            _tokenIds.increment();
       }
        
        for (uint256 i = 1; i <= tokenamt; i++) {
            uint256 newTokenId = _tokenIds.current();
            _safeMint(addr,newTokenId);
            _tokenIds.increment();
        }
        }
      //  balances[msg.sender] += tokenamt;

   


              //error InsufficientBalance(uint requested, uint available);
  //     function mintKingEdition(address addr, uint tokenamt) onlyIfWhitelisted(addr) public payable{
  //      uint mintKingEditionAmt= 3;
  //            require(msg.value >= mintPrice);
  //      require(tokenamt == mintKingEditionAmt || tokenamt == mintAmt ,"You can only mint 3 token per wallet");
  //        require(tokenamt > 0, "need to mint at least 1 NFT");
  //      require(tokenamt == 3 || tokenamt == mintAmt,"You have exceeded the max token limit per wallet");
  //      require(whitelisted[msg.sender],"only whitelisted addresses can call this function");
  //       balances[msg.sender] += tokenamt;
        

  //  }

   function enableWhitelistState() public onlyAdmin{
       enableWhitelist = !enableWhitelist;

   }

}