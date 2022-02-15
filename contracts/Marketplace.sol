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

    function createMarketItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant{
      require(price > 0, "Price must be at-least 1wei");
      require(msg.value==listingPrice, "Price must be equal to listing price"); // user must send listing price as payment

      _itemIds.increment();
      uint256 itemId = _itemIds.current();

      idToMarketItems[itemId] = MarketItem({
        itemId,
        nftContract,
        tokenId,
        payable(msg.sender),
        payable(address(0)), // owner setting as empty address
        price,
        false
      });

      IERC721.transferFrom(msg.sender, address(this), itemId); // transfer ownership of the item to the marketplace

      emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, payable(address(0)), price, false);
    }
}
