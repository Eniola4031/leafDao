const {MarkleTree} = require ("markletreejs");
const {Keccak256} = require ("keccak256");
const { keccak256 } = require("ethers/lib/utils");


let whitelist = []

const leafnode= whitelist.map(addr => keccak256(addr));
const MarkleTree = new MarkleTree (leafnode, keccak256, {sortPairs:true});

//get the root hash of the markle tree in hex format

const rootHash= MarkleTree.getRoot();

console.log ("whitelistmarkletree/n", Markletree.toString());















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

