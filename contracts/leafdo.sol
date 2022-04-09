// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


 interface lazyLionI{
    function balanceOf(address owner) external view returns (uint256 balance);
 }

/*
* only those with lazylion token can mint
* 
*/
contract leafDao is ERC721Enumerable, Ownable, ReentrancyGuard{
 using Counters for Counters.Counter;

 Counters.Counter private _tokenIdCounter;

    uint256 public constant mintPrice = 60000000000000000; // 0.06 ether;
    bool public whitelistState = false;
    uint public maxMintKingAmount = 3;
    uint public maxMintLazyAmount = 1;
     uint MaxTokenSupply = 500;
     //this is a test address
    lazyLionI _lazyLion = lazyLionI(0x0fC5025C764cE34df352757e82f7B5c4Df39A836);

             mapping(address => bool) public isWhitelisted;
             mapping(address => bool) public isAdmin;
             mapping(address => uint) public _tokensMintedByAddress;

    constructor()ERC721("leafDAO","LFD"){}
    
/**
   * @dev Throws if called by any account that's not whitelisted.
   */
         modifier onlyWhitelisted {
    require(isWhitelisted[msg.sender],"only whiteListedAddress can mint"); 
    _;
  }
         modifier onlyAdmin(){
    require(isAdmin[msg.sender],"only admin can call this method");  
      _;
   }
  
      event WhitelistedAddressAdded(address addr);

  /**
   * @dev add an address to the whitelist
   * @param addr address
   * @notice true if the address was added to the whitelist, false if the address was already in the whitelist 
   */
  function addToWhitelist(address addr) onlyAdmin public returns(bool success) {
       require(!isWhitelisted[addr], "already whitelisted");
    require(_lazyLion.balanceOf(addr) > 0, "not a lazy lion owner");     
    if (!isWhitelisted[addr]) {
      isWhitelisted[addr] = true;
        emit WhitelistedAddressAdded(addr);
      success = true; 
    }

  }
  function addAsAdmin(address addr) onlyOwner external returns(bool success) {
   require(!isAdmin[addr], "already an admin");
    if (!isAdmin[addr]) {
      isAdmin[addr] = true;
        success = true; 
    }

  }

  /**
  * @notice addrs must an input like below:
  ["0x617F2E2fD72FD9D5503197092aC168c91465E7f2",
  "0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB",
  "0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C"]
  * @notice if 1 out of the several addrs do not have lazy lion, it will revert
   * @dev add addresses to the whitelist
   * @param addrs addresses
   * @notice true if at least one address was added to the whitelist, 
   * false if all addresses were already in the whitelist  
   */

  function addAddressesToWhitelist(address[] memory addrs) onlyAdmin public returns(bool success) {
     // require(_lazyLion.balanceOf(addrs[] memory) > 0, "not a lazy lion owner");     
    for (uint256 i = 0; i < addrs.length; i++) {
      if (addToWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

    /*
    * Only whitelisted lazylion owners can mint
    * those who mint the 1-120 tokens can only mint 1 per wallet
    * those who mint 1-120 will mint free + gas
    */

   function mintLazyEdition(uint _mintAmount) nonReentrant onlyWhitelisted public{
     // Number of tokens can't be 0.
       require(_mintAmount != 0, "Cannot mint 0 tokens");
       _tokensMintedByAddress[msg.sender]  += _mintAmount; //update users record
        //check if address has minted
        require(_tokensMintedByAddress[msg.sender] <= maxMintLazyAmount, "you have exceeded mint limit per wallet");
        uint tokenLeft = totalSupply() + _mintAmount;
        // Check that the number of tokens requested wouldn't exceed what's left.
        require(tokenLeft <= MaxTokenSupply, "Minting would exceed max. supply");
        // Check that the right amount of Ether was sent.
       uint256 mintIndex = totalSupply();
             // For each token requested, mint one.
        for(uint256 i = 0; i < _mintAmount; i++) {
       if(mintIndex <= 120  && mintIndex <= MaxTokenSupply){
             _safeMint(msg.sender, mintIndex);
       }
        }   
   }

   /*
    * If whitelist is enabled,only whitelisted lazylion owners can mint
    * If whitelist is disabled, all lazy lion owners can mint
    * those who mint the 121-500 tokens can only mint 3 per wallet
    *  those who mint the 121-500 must pay 0.06 ether + gas per token
    */
   function mintKingEdition(uint _mintAmount) nonReentrant public payable{
        if(whitelistState == true){
            require(
           isWhitelisted[msg.sender],"whitelist Enabled: only whiteListedAddress can mint"
           ); 
         }
         else{
            require(
           _lazyLion.balanceOf(msg.sender) > 0, "not a lazy lion owner"
            );     

         }
         // Number of tokens can't be 0.
        require(_mintAmount != 0, "Cannot mint 0 tokens");
       _tokensMintedByAddress[msg.sender]  += _mintAmount;//update users record
        //check if address has minted
        require(_tokensMintedByAddress[msg.sender] <= maxMintKingAmount, "you have exceeded mint limit per wallet");
        uint tokenLeft = totalSupply() + _mintAmount;
        // Check that the number of tokens requested wouldn't exceed what's left.
        require(tokenLeft <= MaxTokenSupply, "Minting would exceed max. supply");
        uint pricePerToken = mintPrice * _mintAmount;
        // Check that the right amount of Ether was sent.
        require(pricePerToken<= msg.value, "Not enough Ether sent."); 
       uint256 mintIndex = totalSupply();
               // For each token requested, mint one.
        for(uint256 i = 0; i < _mintAmount; i++) {
       if(mintIndex <= 380  && mintIndex <= MaxTokenSupply){
             _safeMint(msg.sender, mintIndex);
       }
        }
   }


      function changeWhitelistState() public onlyAdmin{
       whitelistState = !whitelistState;

        }
      function getBalance() onlyAdmin public view returns  (uint256) {
        return address(this).balance;
        }

       function changeLazyMintAmt(uint256 _newMint) public onlyAdmin {
        maxMintLazyAmount = _newMint;
        }
       function changeKingMintAmt(uint256 _newMint) public onlyAdmin {
        maxMintKingAmount = _newMint;
         }


         //add withdraw function
         //onlyOwner
         //getcall
  
}


