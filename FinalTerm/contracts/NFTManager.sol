// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTManager is ERC721URIStorage{

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address owner;
    mapping(uint => string) classURI;
    mapping(address => uint256[]) assignedNFT;
    mapping(uint => uint256) notAssignedNFT;

    constructor() ERC721("NFTManager", "ITM") {
        owner = msg.sender;
        classURI[1] = "https://ipfs.io/ipfs/QmVN2BScWLhBwjXPF1g3f1c1UMbSLXQfekuFKjbWTFF65e?filename=kitties_class1.png";
        classURI[2] = "https://ipfs.io/ipfs/QmbYS29BAgbAUo4zAPqkSaYoQ36XCbkwbh9gvoXaKJQmST?filename=kitties_class2.png";
        classURI[3] = "https://ipfs.io/ipfs/QmewmLdPhYaHFoDFvZabqaF3BYgTGVFdiCAPBELVb2iYMd?filename=kitties_class3.png";
        classURI[4] = "https://ipfs.io/ipfs/QmbcQ4Y8rXr5Gp7jGNfSYjsnKtum6y2AxmZ4K3kaCah2j3?filename=kitties_class4.png";
        classURI[5] = "https://ipfs.io/ipfs/QmWuWMeDqwYC9fTAYSYMM1BQkLst6F6joPtGWMkA2fHBfq?filename=kitties_class5.png";
        classURI[6] = "https://ipfs.io/ipfs/QmPKfmwbhecUCpsRfbVaLLAnaXZQBD759yFPd932B8CmbK?filename=kitties_class6.png";
        classURI[7] = "https://ipfs.io/ipfs/Qme4XDJVq2ra2p9RhBr9CTHPE6Gj6dv2gFQCXRLkEDAKbk?filename=kitties_class7.png";
        classURI[8] = "https://ipfs.io/ipfs/QmancqnrSydMcr7v4LMwHSXVWZcnYjeYQMYq5xEcUs4C6W?filename=kitties_class8.png";
    }

    function mintNFT(uint class)
        public
    {
        uint256 newItemId = _tokenIds.current();
        _mint(owner, newItemId);
        _setTokenURI(newItemId, classURI[class]);
        notAssignedNFT[class] = newItemId;

        _tokenIds.increment();
    }

    function assignNFT(address user, uint class)
        public
    {
        safeTransferFrom(owner, user, notAssignedNFT[class]);
        assignedNFT[user].push(notAssignedNFT[class]);
    }
}