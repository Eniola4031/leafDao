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

// .----,  .--.  .---..-.  .-.   .-.   .-. .----. .-. .-. .----.
// | |    / {} \{_   / \ \/ /    | |   | |/  {}  \|  `| |{ {__  
// | `--./  /\  \/    } }  {     | `--.| |\      /| |\  |.-._} }
// `----'`-'  `-'`---' / /\ \    `----'`-' `----' `-' `-'`----'


/// @title XTRA_for_LIONS
/// @notice EXTRALIONS claimable by LazyLion owners
/// @author Eniola Agboola
/// @dev ERC721 claimable by members of a merkle tree
contract XTRA_for_LIONS is ERC721Enumerable, ReentrancyGuard, AccessControl {
 using Counters for Counters.Counter;

 Counters.Counter private _tokenIdCounter;

     /// ==================== State Variables  =======================

    bytes32 public constant MANAGER_ROLE = keccak256("manager");
    bool public whitelistState;
    uint256 public constant mintPrice = 60000000000000000; // 0.06 ether;
    uint public maxMintKingAmount = 3;
    uint public maxMintLazyAmount = 1;
    uint public MaxTokenSupply = 500;
    /// @notice whiteliste address inclusion root
     bytes32 public  merkleRoot;
     //this is a test lazyLion address
    lazyLionI _lazyLion = lazyLionI(0x8FCD0A31f825FDb16D674279a2883Ea4ACfe6368);


    /// ==================== mappings =======================
             mapping(address => bool) public isWhitelisted;
             mapping(address => uint) public _tokensMintedByAddress;



    /// ==================== constructor =======================
    /// @dev _merkleRoot must append "0x" prefix with the hash
    /// @dev Grants `DEFAULT_ADMIN_ROLE` to the account that deploys the contract.
    /// See {ERC20-constructor}.

    constructor(bytes32 _merkleRoot, address _admin)ERC721("XTRA_for_LIONS","EXTRALIONS"){
         address admin = _admin;
          merkleRoot = _merkleRoot; // Update root
      _setRoleAdmin(MANAGER_ROLE, DEFAULT_ADMIN_ROLE);

      _setupRole(DEFAULT_ADMIN_ROLE,_msgSender());// The creator of the contract is the default admin
      _setupRole(DEFAULT_ADMIN_ROLE,admin);// We add a custom admin which could also be the gnosis instance     
    }


       /// ====================== events =======================
      event UpdatedRoot(bytes32 _newRoot);
      event managerAdded(address account);
      event mintedLazyEdition(address addr, uint256 _mintAmount);
      event mintedKingEdition(address addr, uint256 _mintAmount);
      event safeAddressAdded(address newInstance);


    /// ====================== functions ========================

     /// @notice Updates the merkleRoot with the given new root
    /// @param _newRoot new merkleRoot to work with
  function updateMerkleRoot(bytes32 _newRoot) onlyRole(MANAGER_ROLE) external {
    merkleRoot = _newRoot;
    emit UpdatedRoot(_newRoot);
  }

   /// @notice checks if the address is a member of the tree
   /// @dev the proof and root are gotten from the MerkleTree script
   /// @param _merkleProof to check if to is part of merkle tree
    /// @notice Only whitelisted lazylion owners can mint
   function mintLazyEdition(uint _mintAmount, bytes32[] calldata _merkleProof) nonReentrant external{
     require(_lazyLion.balanceOf(msg.sender) > 0);
  //generate a leaf node to verify merkle proof, or revert if not in tree
     bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
     //checks for valid proof
    require(MerkleProof.verify(_merkleProof,merkleRoot,leaf),"invalid merkle proof");
                 isWhitelisted[msg.sender] = true;
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
    /// @param _merkleProof to make sure address is whitelisted
   function mintKingEdition(uint _mintAmount, bytes32[] calldata _merkleProof) nonReentrant external payable{
     //generate a leaf node to verify merkle proof, or revert if not in tree
     bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
     //checks for valid proof
    require(MerkleProof.verify(_merkleProof,merkleRoot,leaf),"invalid merkle proof");
                 isWhitelisted[msg.sender] = true;
        if(whitelistState == true){
            require(
            isWhitelisted[msg.sender] = true,"whitelist Enabled: only whiteListedAddress can mint"
           ); 
         }else{
          (_lazyLion.balanceOf(msg.sender) > 0, "Whitelist disabled:not a lazy lion owner");     
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


      function changeWhitelistState() public onlyRole(MANAGER_ROLE){
       whitelistState = !whitelistState;

        }
      function getBalance() onlyRole(MANAGER_ROLE) public view returns(uint256) {
        return address(this).balance;
        }

       function changeLazyMintAmt(uint256 _newMint) public onlyRole(MANAGER_ROLE) {
        maxMintLazyAmount = _newMint;
        }
       function changeKingMintAmt(uint256 _newMint) public onlyRole(MANAGER_ROLE) {
        maxMintKingAmount = _newMint;
         }
// only role who have access to the gnosis safe can call this method and it will be deposit in gnosis for mulsig to sig
         function withdraw() onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant public returns(bool){
               (bool sent,) = payable(msg.sender).call{value: getBalance()}("");
            require(sent,"Ether not sent:failed transaction");
                return true;
         }
    /// @dev Add an account to the manager role. Restricted to admins.
        function addAsManager(address account) public onlyRole(DEFAULT_ADMIN_ROLE)
       {
         require(hasRole(MANAGER_ROLE,account) == false,"Already a manager");
           grantRole(MANAGER_ROLE, account);

            emit managerAdded(account);
       }
        
      // Create a bool check to see if a account address has the role admin
      function isAdmin(address account) public view returns(bool)
      {
           return hasRole(DEFAULT_ADMIN_ROLE, account);
      }
        // Create a bool check to see if a account address has the role admin
      function isManager(address account) public view returns(bool)
      {
           return hasRole(MANAGER_ROLE, account);
      }

          ///@custom:interface for overridding the supportInterface method on AccessControl and ERC721Enumerable
       function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

         ///@custom:interface for overridding the supportInterface method on AccessControl and ERC721Enumerable
        function _beforeTokenTransfer(address from, address to,uint256 tokenId) internal virtual override(ERC721Enumerable) {
                  super._beforeTokenTransfer(from, to, tokenId);

        }


}
