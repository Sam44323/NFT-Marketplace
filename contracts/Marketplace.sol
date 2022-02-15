// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; // for stopping bombarded calling to contracts

contract Marketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds; // for the items listed on the marketplace
    Counters.Counter private _itemSold;

    address payable owner; // setting as payable as the owner will be paid some value as commission for the sale
    uint256 listingPrice = 0.025 ether; // as for polygon so in terms of matic

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    };

    event MarketItemCreated{
      uint indexed itemId;
      address indexed nftContract;
      uint256 indexed tokenId;
      address seller;
      address owner;
      uint256 price;
      bool sold;
    }

    mapping(uint256 => MarketItem) private _idToMarketItems;

    constructor() {
        owner = payable(msg.sender);
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }
}
