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

    // Market-item structure
    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // event when a market items is created
    event MarketItemCreated(
        uint256 indexed itemI,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    mapping(uint256 => MarketItem) private _idToMarketItems; // mapping of itemId to market item

    constructor() {
        owner = payable(msg.sender);
    }

    /*
   @dev Gets the listing price for the marketplace and returns it
   @return the listing price for the marketplace
   */

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    /*
   @dev Gets the listing price for the marketplace and returns it
   @param nftContract the address of the NFT contract
   @param tokenId the tokenId of the NFT
   @param price the price of the NFT to be listed for
   @return event
   */

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be at-least 1wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        ); // user must send listing price as payment

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        _idToMarketItems[itemId] = MarketItem({
            itemId: itemId,
            nftContract: nftContract,
            tokenId: tokenId,
            seller: payable(msg.sender),
            owner: payable(address(0)), // owner setting as empty address
            price: price,
            sold: false
        });

        IERC721(nftContract).transferFrom(msg.sender, address(this), itemId); // transfer ownership of the item to the marketplace

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }

    /*
   @dev Buying an item from the marketplace
   @param nftContract the address of the NFT contract
   @param itemId the item-id of the NFT
   @return event
   */

    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        uint256 price = _idToMarketItems[itemId].price;
        uint256 tokenId = _idToMarketItems[itemId].tokenId;

        require(
            msg.value == price,
            "Price must be equal to the price of the item for purchasing this item"
        );

        _idToMarketItems[itemId].seller.transfer(msg.value); // sending the selling price to the seller
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId); // transfer ownership of the item to the buyer
        _idToMarketItems[itemId].owner = payable(msg.sender);
        _idToMarketItems[itemId].sold = true;
        _itemSold.increment();

        payable(owner).transfer(listingPrice); // sending the listing price to the owner of the contract
    }

    /*
    @dev gets all the items for sale but not sold
    @return all the items for sale but not sold
   */

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemsCount = _itemIds.current() - _itemSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemsCount); // creating an array of unsold items
        for (uint256 index = 0; index < itemCount; index++) {
            if (_idToMarketItems[index + 1].owner == address(0)) {
                uint256 currentId = _idToMarketItems[index + 1].itemId;
                MarketItem memory item = _idToMarketItems[currentId];
                items[currentIndex] = item;
                currentIndex++;
            }
        }

        return items;
    }

    /*
     @dev gets all the items owned by the user
     @return all the items owned by the user
   */

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 index = 0; index < totalItemCount; index++) {
            if (_idToMarketItems[index + 1].owner == msg.sender) {
                itemCount++;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount); // creating an array of items owned by the user
        for (uint256 index = 0; index < totalItemCount; index++) {
            if (_idToMarketItems[index + 1].owner == msg.sender) {
                uint256 currentId = index + 1;
                MarketItem memory item = _idToMarketItems[currentId];
                items[currentIndex] = item;
                currentIndex++;
            }
        }

        return items;
    }

    /*
      @dev gets all theh items created by the user
      @return all the items created by the user
   */

    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (_idToMarketItems[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (_idToMarketItems[i + 1].seller == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = _idToMarketItems[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
