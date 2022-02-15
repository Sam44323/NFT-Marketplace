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
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    event MarketItemCreated(
        uint256 indexed itemI,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    mapping(uint256 => MarketItem) private _idToMarketItems;

    constructor() {
        owner = payable(msg.sender);
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

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

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() - _itemSold.current();
        uint256 currentIndex = 0;
    }
}
