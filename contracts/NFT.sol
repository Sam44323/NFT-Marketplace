// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // for setting the token_uri
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress; // the contract address with which we want our NFT to interact

    constructor(address marketplaceAddress)
        ERC721("Hakuna Matata Tokens", "HKT")
    {
        contractAddress = marketplaceAddress;
    }

    function createToken(string memory _tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, _tokenURI); // setting the token_uri after minting
        setApprovalForAll(contractAddress, true); // setting the approval for the marketplace

        return newItemId;
    }
}
