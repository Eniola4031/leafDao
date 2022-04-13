const { MerkleTree } = require('merkletreejs')
const {Keccak256} = require ("keccak256");
const { keccak256 } = require("ethers/lib/utils");


let whitelist =["0x617F2E2fD72FD9D5503197092aC168c91465E7f2",
"0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB",
"0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C",
"0xE3A9a11232f4D52786CA61f56bB7Fb01b00C80cd",
"0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
"0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
"0x617F2E2fD72FD9D5503197092aC168c91465E7f2",
"0xdD870fA1b7C4700F2BD7f44238821C26f7392148",
"0x583031D1113aD414F02576BD6afaBfb302140225",
"0x11056D6c881B5239A1b4A8bF5770D6C38C6b9131"
];

const leafnode= whitelist.map(addr => keccak256(addr));
const tree = new MerkleTree (leafnode, keccak256, {sortPairs:true});

//get the root hash of the markle tree in hex format
const rootHash= MerkleTree.getRoot();

console.log ("whitelistmerkletree/n", Merkletree.toString());















// <!DOCTYPE html>
// <html lang="en">
// <head>
//     <meta charset="UTF-8">
//     <meta name="viewport" content="width=device-width, initial-scale=1.0">
//     <title>Document</title>
//     <script src="https://cdn.jsdelivr.net/npm/merkletreejs@latest/merkletree.js"></script>
//     <script src="https://cdn.jsdelivr.net/npm/keccak256@latest/keccak256.js"></script>
// </head>
// <body>
//    <script>
//    const { MerkleTree } = require('merkletreejs')
// const keccak256 = require('keccak256')

// let addrs=[""]
// const leaves = addrs.map(x => keccak256(x))
// const tree = new MerkleTree(leaves, keccak256)
// const root = tree.getRoot().toString('hex')
// const leaf = keccak256('addrs')
// const proof = tree.getProof(leaf)
// console.log(tree.verify(proof, leaf, root)) // true


// const badLeaves =addrs.map(x => keccak256(x))
// const badTree = new MerkleTree(badLeaves, SHA256)
// const badLeaf = keccak256('addrs')
// const badProof = tree.getProof(badLeaf)
// console.log(tree.verify(badProof, leaf, root)) // false

// console.log(tree.toString())

// </script>
// </body>
// </html>

