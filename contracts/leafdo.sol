// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/// ================= Imports ==================

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


/// @title This is the LazyLion interface.
 interface lazyLionI{
    function balanceOf(address owner) external view returns (uint256 balance);
 }

/// @title XTRA_for_LIONS
/// @notice EXTRALIONS claimable by LazyLion owners
/// @author Eniola Agboola
/// @dev ERC721 claimable by members of a merkle tree
contract XTRA_for_LIONS is ERC721Enumerable, ReentrancyGuard, AccessControl {
 using Counters for Counters.Counter;

 Counters.Counter private _tokenIdCounter;

     /// ==================== State Variables  =======================

    bytes32 public constant managerRole = keccak256("manager");
    bytes32 public constant whitelistRole = keccak256("whitelisted");
    bytes32 public constant adminRole = keccak256("admin");
    bool public whitelistState;
    uint256 public constant mintPrice = 60000000000000000; // 0.06 ether;
    uint public maxMintKingAmount = 3;
    uint public maxMintLazyAmount = 1;
    uint public MaxTokenSupply = 500;
    /// @notice whiteliste address inclusion root
     bytes32 public  merkleRoot;
     //this is a test lazyLion address
    lazyLionI _lazyLion = lazyLionI(0x1E44490E45BB9C21397De48d7f534582cE0dd51d);


    /// ==================== mappings =======================
             mapping(address => bool) public isWhitelisted;
             mapping(address => uint) public _tokensMintedByAddress;



    /// ==================== constructor =======================
    constructor(bytes32 _merkleRoot)ERC721("XTRA_for_LIONS","EXTRALIONS"){
              merkleRoot = _merkleRoot; // Update root
                  _setRoleAdmin(adminRole, adminRole);
                   _setRoleAdmin(managerRole, adminRole);
                  _setRoleAdmin(whitelistRole, managerRole);

                  _setupRole(adminRole,_msgSender());
                  _setupRole(adminRole,address(this));

    }

       /// ====================== events =======================
      event UpdatedRoot(bytes32 _newRoot);
      event WhitelistedAddressAdded(address addr);
      event adminAdded(address addr);
      event adminRemoved(address addr);
      event mintedLazyEdition(address addr, uint256 _mintAmount);
      event mintedKingEdition(address addr, uint256 _mintAmount);
      event balanceWithdrawn(address to, uint256 balance);


    /// ====================== functions ========================

     /// @notice Updates the merkleRoot with the given new root
    /// @param _newRoot new merkleRoot to work with
  function updateMerkleRoot(bytes32 _newRoot) onlyRole(managerRole) external {
    merkleRoot = _newRoot;
    emit UpdatedRoot(_newRoot);
  }

   /// @notice checks if the address is a member of the tree
   /// @dev the proof and root are gotten from the MerkleTree script
   /// @param to address to be checked if whitelisted
   /// @param _merkleProof hash
   function verifyWhitlisted(address to, bytes32[] calldata _merkleProof) onlyRole(managerRole) external {
          //generate a leaf node to verify merkle proof, or revert if not in tree
     bytes32 leaf = keccak256(abi.encodePacked(to));
     //checks for valid proof
    require(MerkleProof.verify(_merkleProof,merkleRoot,leaf),"invalid merkle proof");
               hasRole(whitelistRole, to) == true;
               isWhitelisted[to] = true;
  }

 
    /// @notice Only whitelisted lazylion owners can mint
   function mintLazyEdition(uint _mintAmount) nonReentrant onlyRole(whitelistRole)external{
     // Number of tokens can't be 0.
       require(_mintAmount != 0, "Cannot mint 0 tokens");
       _tokensMintedByAddress[msg.sender] += _mintAmount; //update users record
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

        emit mintedLazyEdition(msg.sender, _mintAmount);
   }

    /// @notice only whitelisted address can mint if whitelist is disabled
    /// @notice members can only mint this edition if they pay the mintPrice
    /// @param _mintAmount is the min token amount
   function mintKingEdition(uint _mintAmount) onlyRole(whitelistRole) nonReentrant external payable{
        if(whitelistState == true){
            require(
           hasRole(whitelistRole, msg.sender),"whitelist Enabled: only whiteListedAddress can mint"
           ); 
         }else{
          (_lazyLion.balanceOf(msg.sender) > 0, "not a lazy lion owner");     
         }
         // Number of tokens can't be 0.
        require(_mintAmount != 0, "Cannot mint 0 tokens");
      //  _tokensMintedByAddress[msg.sender][msg.sender]  += _mintAmount;//update users record
             _tokensMintedByAddress[msg.sender]  += _mintAmount;//update users record

        //check if address has minted
        require(_tokensMintedByAddress[msg.sender] <= maxMintKingAmount, "you have exceeded mint limit per wallet");
        uint tokenLeft = totalSupply() + _mintAmount;
        // Check that the number of tokens requested wouldn't exceed what's left.
        require(tokenLeft <= MaxTokenSupply, "Minting would exceed max. supply");
        uint pricePerToken = mintPrice * _mintAmount;
        // Check that the right amount of Ether was sent.
        require(pricePerToken <= msg.value, "Not enough Ether sent."); 
       uint256 mintIndex = totalSupply();
               // For each token requested, mint one.
        for(uint256 i = 0; i < _mintAmount; i++) {
       if(mintIndex <= 380  && mintIndex <= MaxTokenSupply){
             _safeMint(msg.sender, mintIndex);
       }
        }
                emit mintedKingEdition(msg.sender, _mintAmount);

   }


      function changeWhitelistState() public onlyRole(managerRole){
       whitelistState = !whitelistState;

        }
      function getBalance() onlyRole(managerRole) public view returns  (uint256) {
        return address(this).balance;
        }

       function changeLazyMintAmt(uint256 _newMint) public onlyRole(managerRole) {
        maxMintLazyAmount = _newMint;
        }
       function changeKingMintAmt(uint256 _newMint) public onlyRole(managerRole) {
        maxMintKingAmount = _newMint;
         }

            //withdraw all ether
         function withdraw() onlyRole(managerRole) nonReentrant public returns(bool){
           address payable gnosWallet = payable(msg.sender);
               (bool sent,) = gnosWallet.call{value: getBalance()}("");
            require(sent,"Ether not sent:failed transaction");
                return true;

               // emit balanceWithdrawn(msg.sender, address(this).balance);

         }


                  ///@custom:interface for overridding the supportInterface method on AccessControl and ERC721Enumerable
                   function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}
