
const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

// const { keccak256 } = require("ethers/lib/utils");


let whitelist =  ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
 "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
 "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
"0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]

// The leaves, tree, and root are all PRE-DETERMINED prior to adding to whitelist

//leaf node
const leaves = whitelist.map(x => keccak256(x))
//console.log("leaves value",leaves)
const tree = new MerkleTree(leaves, keccak256,{sortPairs:true})
//get the root hash of the markle tree in hex format
const root = tree.getRoot().toString('hex')
//console.log ("whitelist Merkle Tree\n", tree.toString());
console.log("Root Hash: ", root);

const whitelistAddr = leaves[2];
//console.log("leaves", whitelistAddr);
const proof = tree.getHexProof(whitelistAddr)
console.log("Merkle Proof:", proof);
const verified = tree.verify(proof, whitelistAddr, root)

console.log(verified) // true





// let whitelist =["0x617F2E2fD72FD9D5503197092aC168c91465E7f2",
// "0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB",
// "0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C",
// "0xE3A9a11232f4D52786CA61f56bB7Fb01b00C80cd",
// "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
// "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
// "0x617F2E2fD72FD9D5503197092aC168c91465E7f2",
// "0xdD870fA1b7C4700F2BD7f44238821C26f7392148",
// "0x583031D1113aD414F02576BD6afaBfb302140225",
// "0x11056D6c881B5239A1b4A8bF5770D6C38C6b9131"
// ];
