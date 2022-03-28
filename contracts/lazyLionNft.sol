// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/EnumerableMap.sol";
//import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

 
contract LazyLions is ERC721, Ownable {
    using SafeMath for uint256;

    string public LION_PROVENANCE = ""; // IPFS PROVENANCE TO BE ADDED WHEN SOLD OUT

    string public LICENSE_TEXT = "";

    bool licenseLocked = false;

    uint256 public lionPrice = 50000000000000000; // 0.050 ETH

    uint256 public constant maxLionPurchase = 20;

    uint256 public constant MAX_LIONS = 10000;

    bool public saleIsActive = false;

    uint256 public lionReserve = 250; // Reserve 250 Lions for team & community (Used in giveaways, events etc...)

    event licenseisLocked(string _licenseText);

    constructor() ERC721("Lazy Lions", "LION") {}

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        msg.sender.transfer(balance);
    }

    function reserveLions(address _to, uint256 _reserveAmount)
        public
        onlyOwner
    {
        uint256 supply = totalSupply();
        require(
            _reserveAmount > 0 && _reserveAmount <= lionReserve,
            "Not enough reserve left for team"
        );
        for (uint256 i = 0; i < _reserveAmount; i++) {
            _safeMint(_to, supply + i);
        }
        lionReserve = lionReserve.sub(_reserveAmount);
    }

    function setProvenanceHash(string memory provenanceHash) public onlyOwner {
        LION_PROVENANCE = provenanceHash;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 index;
            for (index = 0; index < tokenCount; index++) {
                result[index] = tokenOfOwnerByIndex(_owner, index);
            }
            return result;
        }
    }

    // Returns the license for tokens
    function tokenLicense(uint256 _id) public view returns (string memory) {
        require(_id < totalSupply(), "CHOOSE A LION WITHIN RANGE");
        return LICENSE_TEXT;
    }

    // Locks the license to prevent further changes
    function lockLicense() public onlyOwner {
        licenseLocked = true;
        emit licenseisLocked(LICENSE_TEXT);
    }

    // Change the license
    function changeLicense(string memory _license) public onlyOwner {
        require(licenseLocked == false, "License already locked");
        LICENSE_TEXT = _license;
    }

    function mintLion(uint256 numberOfTokens) public payable {
        require(saleIsActive, "Sale must be active to mint Lion");
        require(
            numberOfTokens > 0 && numberOfTokens <= maxLionPurchase,
            "Can only mint 20 tokens at a time"
        );
        require(
            totalSupply().add(numberOfTokens) <= MAX_LIONS,
            "Purchase would exceed max supply of Lions"
        );
        require(
            msg.value >= lionPrice.mul(numberOfTokens),
            "Ether value sent is not correct"
        );

        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_LIONS) {
                _safeMint(msg.sender, mintIndex);
            }
        }
    }

    function setLionPrice(uint256 newPrice) public onlyOwner {
        lionPrice = newPrice;
    }
}