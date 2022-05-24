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

    constructor() ERC721("NFTManager", "ITM") {
        owner = msg.sender;
        classURI[1] = "https://ipfs.io/ipfs/QmQtBoDqsD2GPQwd8PEs58aAuGeNDy8n1u791iXMVjP8Nt?filename=images.png";
        classURI[2] = "https://ipfs.io/ipfs/QmQtBoDqsD2GPQwd8PEs58aAuGeNDy8n1u791iXMVjP8Nt?filename=images.png";
        classURI[3] = "https://ipfs.io/ipfs/QmQtBoDqsD2GPQwd8PEs58aAuGeNDy8n1u791iXMVjP8Nt?filename=images.png";
        classURI[4] = "https://ipfs.io/ipfs/QmQtBoDqsD2GPQwd8PEs58aAuGeNDy8n1u791iXMVjP8Nt?filename=images.png";
        classURI[5] = "https://ipfs.io/ipfs/QmQtBoDqsD2GPQwd8PEs58aAuGeNDy8n1u791iXMVjP8Nt?filename=images.png";
        classURI[6] = "https://ipfs.io/ipfs/QmQtBoDqsD2GPQwd8PEs58aAuGeNDy8n1u791iXMVjP8Nt?filename=images.png";
        classURI[7] = "https://ipfs.io/ipfs/QmQtBoDqsD2GPQwd8PEs58aAuGeNDy8n1u791iXMVjP8Nt?filename=images.png";
        classURI[8] = "https://ipfs.io/ipfs/QmQtBoDqsD2GPQwd8PEs58aAuGeNDy8n1u791iXMVjP8Nt?filename=images.png";
    }

    function mintNFT(uint class)
        public 
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        _mint(owner, newItemId);
        _setTokenURI(newItemId, classURI[class]);

        _tokenIds.increment();
        return newItemId;
    }

    function assignNFT(address user, uint tokenId)
        public
    {
        safeTransferFrom(owner, user, tokenId);
    }



}
