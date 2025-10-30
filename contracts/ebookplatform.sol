// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EbookPlatform {
    // 📚 Struct to represent an Ebook
    struct Ebook {
        uint256 id;
        address payable author; // Address of the book's creator, can receive payments
        string title;
        string contentHash; // IPFS or similar hash for the book content
        uint256 price; // Price in Wei
        bool isPublished;
    }

    // A mapping from an auto-incrementing ID to the Ebook struct
    mapping(uint256 => Ebook) public ebooks;
    uint256 public nextEbookId = 1;

    // Event emitted when a new book is published
    event EbookPublished(uint256 id, address author, string title, uint256 price);
    // Event emitted when a book is purchased
    event EbookPurchased(uint256 id, address purchaser, uint256 amount);

    // --- CORE FUNCTIONS ---

    /**
     * @dev Allows an author to publish a new ebook to the platform.
     * @param _title The title of the book.
     * @param _contentHash The content hash (e.g., IPFS) pointing to the ebook file.
     * @param _price The price of the ebook in Wei.
     */
    function publishEbook(
        string memory _title,
        string memory _contentHash,
        uint256 _price
    ) public {
        require(bytes(_title).length > 0, "Title cannot be empty.");
        require(_price > 0, "Price must be greater than zero.");

        // Create the new Ebook
        ebooks[nextEbookId] = Ebook({
            id: nextEbookId,
            author: payable(msg.sender),
            title: _title,
            contentHash: _contentHash,
            price: _price,
            isPublished: true
        });

        emit EbookPublished(nextEbookId, msg.sender, _title, _price);

        // Increment ID for the next book
        nextEbookId++;
    }

    /**
     * @dev Allows a user to purchase a published ebook.
     * The ETH sent is transferred directly to the author.
     * @param _ebookId The ID of the book to purchase.
     */
    function purchaseEbook(uint256 _ebookId) public payable {
        Ebook storage ebook = ebooks[_ebookId];

        // Basic checks
        require(ebook.isPublished, "Ebook is not published or does not exist.");
        require(msg.value == ebook.price, "Please send the exact price.");
        require(msg.sender != ebook.author, "Author cannot buy their own book.");

        // Transfer the payment directly to the author
        (bool success, ) = ebook.author.call{value: msg.value}("");
        require(success, "Payment failed.");

        // In a real application, you would grant access to the contentHash
        // (e.g., by logging the buyer's address or minting an NFT).

        emit EbookPurchased(_ebookId, msg.sender, msg.value);
    }

    /**
     * @dev Allows an author to update the price of their published ebook.
     * @param _ebookId The ID of the book to update.
     * @param _newPrice The new price of the ebook in Wei.
     */
    function updateEbookPrice(uint256 _ebookId, uint256 _newPrice) public {
        Ebook storage ebook = ebooks[_ebookId];

        require(ebook.isPublished, "Ebook does not exist.");
        // Only the original author can update the price
        require(msg.sender == ebook.author, "Only the author can update the price.");
        require(_newPrice > 0, "New price must be greater than zero.");

        // Update the price
        ebook.price = _newPrice;
    }
}

