// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721URIStorage, Pausable, Ownable(msg.sender) {

    string baseURI;
    string constant TOKEN_URI =
        "https://ipfs.io/ipfs/bafkreidctfix3k6vigkgjolvw3jaredznire4v4abt4pjut7mooudh3jie";
    uint256 internal tokenId;
    constructor() ERC721("nft", "nft") {
        
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to) payable public  {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, TOKEN_URI);
        unchecked {
            tokenId++;
        }
    }

  }



