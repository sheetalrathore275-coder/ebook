// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EBook {
    // State Variables
    address payable public owner;
    uint256 public bookPriceInWei; // Price of the book in Wei

    // Mappings to track who has purchased the book
    mapping(address => bool) public hasPurchased;
    // An array to keep a list of all buyers
    address[] public buyerAddresses;

    // Events to log important actions
    event PriceUpdated(uint256 newPrice);
    event BookPurchased(address buyer, uint256 amountPaid);
    
    // The book content itself would be stored off-chain (e.g., IPFS, web server)
    // and its access link would be provided to the buyer off-chain,
    // but the contract handles the financial/access logic.

    // Constructor: Runs only once when the contract is deployed
    constructor(uint256 initialPriceInWei) {
        owner = payable(msg.sender);
        bookPriceInWei = initialPriceInWei;
    }

    // --- Core Function 1: Set/Update the Book Price ---
    /**
     * @dev Allows the owner to update the price of the book.
     * @param _newPriceInWei The new price in Wei.
     */
    function setBookPrice(uint256 _newPriceInWei) public {
        // Only the contract owner can call this function
        require(msg.sender == owner, "Only the owner can set the price.");
        
        bookPriceInWei = _newPriceInWei;
        emit PriceUpdated(_newPriceInWei);
    }

    // --- Core Function 2: Purchase the Book ---
    /**
     * @dev Allows a user to purchase the book by sending the correct amount of Ether.
     */
    function purchaseBook() public payable {
        // 1. Check if the user has already purchased the book
        require(!hasPurchased[msg.sender], "You have already purchased this book.");
        
        // 2. Check if the sent Ether (msg.value) matches the current book price
        require(msg.value >= bookPriceInWei, "Ether sent is less than the book price.");
        
        // 3. Process the purchase
        hasPurchased[msg.sender] = true;
        buyerAddresses.push(msg.sender);
        
        // 4. Refund any excess Ether sent
        if (msg.value > bookPriceInWei) {
            payable(msg.sender).transfer(msg.value - bookPriceInWei);
        }

        emit BookPurchased(msg.sender, bookPriceInWei);
    }
    
    // --- Core Function 3: Withdraw Funds ---
    /**
     * @dev Allows the owner to withdraw all funds accumulated from sales.
     */
    function withdrawFunds() public {
        require(msg.sender == owner, "Only the owner can withdraw funds.");
        
        // Transfer the entire contract balance to the owner
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Withdrawal failed.");
    }
}
