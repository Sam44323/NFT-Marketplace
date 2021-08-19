// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; // for giving ids for tokens
    address contractAddress; // address of the marketplace where we want the nft to interact and vice-versa

    constructor(address marketplaceAddress) ERC721("Metaverse Tokens", "METT"){
      contractAddress = marketplaceAddress
    }

    // function for minting new tokens

    function createTokens(string memory tokenURI) public returns(uint){
      _tokenIds.increment();
      uint256 newItemId = _tokenIds.current();

      _mint(msg.sender, newItemId); // minting the token
      _setTokenURI(newItemId, tokenURI);
      setApprovalForAll(contractAddress, true); // gives the marketplace the approval to transact this token between users from within another contract
      return newItemId;
    }
}
