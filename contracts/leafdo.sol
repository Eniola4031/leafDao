// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/// ================= Imports ==================

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title This is the LazyLion interface.
 interface lazyLionI{
    function balanceOf(address owner) external view returns (uint256 balance);
 }

/// @title XTRA_for_LIONS
/// @notice EXTRALIONS claimable by LazyLion owners
/// @author Eniola Agboola
/// @dev ERC721 claimable by members of a merkle tree
contract XTRA_for_LIONS is ERC721Enumerable, Ownable, ReentrancyGuard{
 using Counters for Counters.Counter;

 Counters.Counter private _tokenIdCounter;
 

    uint256 public constant mintPrice = 60000000000000000; // 0.06 ether;
    bool public whitelistState = false;
    uint public maxMintKingAmount = 3;
    uint public maxMintLazyAmount = 1;
    uint public MaxTokenSupply = 500;
    /// @notice whiteliste address inclusion root
     bytes32 public  merkleRoot;
     //this is a test lazyLion address
    lazyLionI _lazyLion = lazyLionI(0xd9145CCE52D386f254917e481eB44e9943F39138);

    /// ==================== mappings =======================
             mapping(address => bool) public isWhitelisted;
             mapping(address => bool) public isAdmin;
             mapping(address => uint) public _tokensMintedByAddress;

    /// ==================== constructor =======================
    constructor(bytes32 _merkleRoot)ERC721("XTRA_for_LIONS","EXTRALIONS"){
              merkleRoot = _merkleRoot; // Update root

    }

    
    /// ==================== modifier =======================

   /// @dev Throws if called by any account that's not whitelisted.
         modifier onlyWhitelisted {
    require(isWhitelisted[msg.sender] = true,"only whiteListedAddress can mint"); 
    _;
  }
         modifier onlyAdmin(){
    require(isAdmin[msg.sender],"only admin can call this method");  
      _;
   }

       /// ==================== events =======================
      event UpdatedRoot(bytes32 _newRoot);
      event WhitelistedAddressAdded(address addr);
      event adminAdded(address addr);
      event adminRemoved(address addr);
      event mintedLazyEdition(address addr, uint256 _mintAmount);
      event mintedKingEdition(address addr, uint256 _mintAmount);
      event balanceWithdrawn(address to, uint256 balance);

    /// ==================== error handling =======================
        /// @notice Thrown if address/amount are not part of Merkle tree
        error NotInMerkle();


    /// ==================== functions =======================

     /// @notice Updates the merkleRoot with the given new root
  /// @param _newRoot new merkleRoot to work with
  function updateMerkleRoot(bytes32 _newRoot) external onlyOwner {
    merkleRoot = _newRoot;
    emit UpdatedRoot(_newRoot);
  }

  /// @notice Owner needs to add themselve as admin to add whitelist
  function addAsAdmin(address addr) onlyOwner external returns(bool success) {
   require(!isAdmin[addr], "already an admin");
    if (!isAdmin[addr]) {
      isAdmin[addr] = true;
        success = true; 
    }
                      emit adminAdded(addr);
  }
  

   /// @notice checks if the address is a member of the tree
   /// @dev the proof and root are gotten from the MerkleTree script
   /// @param to address to be checked if whitelisted
   /// @param _merkleProof hash
   function checkIfWhitlisted(address to, bytes32[] calldata _merkleProof) onlyAdmin external {
     require(!isWhitelisted[to], "already added to whitelisted");
     //generate a leaf node to verify merkle proof, or revert if not in tree
     bytes32 leaf = keccak256(abi.encodePacked(to));
     //checks for valid proof
    require(MerkleProof.verify(_merkleProof,merkleRoot,leaf),"invalid merkle proof");
    isWhitelisted[to] = true;

  }

 
    /// @notice Only whitelisted lazylion owners can mint
   function mintLazyEdition(uint _mintAmount) nonReentrant onlyWhitelisted external{
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

        emit mintedLazyEdition(msg.sender, _mintAmount);
   }

    /// @notice only whitelisted address can mint if whitelist is disabled
    /// @notice members can only mint this edition if they pay the mintPrice
    /// @param _mintAmount is the min token amount
   function mintKingEdition(uint _mintAmount) nonReentrant external payable{
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

            //withdraw all ether
         function withdraw() onlyOwner nonReentrant public payable returns(bool){
           address payable gnos = payable(msg.sender);
               gnos.transfer(getBalance());
                return true;

             //    emit balanceWithdrawn(msg.sender, address(msg.sender).balance);

         }

            //remove admin
        function removeAdmin(address addr) onlyOwner external returns(bool success) {
                 require(isAdmin[addr], "Address not an admin");
               if (isAdmin[addr]) {
             isAdmin[addr] = false;
                success = true; 
        }

                    emit adminRemoved(addr);

                  }

}

