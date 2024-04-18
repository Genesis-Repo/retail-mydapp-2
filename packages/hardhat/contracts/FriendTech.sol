// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing the ERC721 Enumerable extension from OpenZeppelin, which adds enumeration functionality to the ERC721 standard
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// Importing the Ownable contract from OpenZeppelin, which allows for setting an owner with exclusive access control
import "@openzeppelin/contracts/access/Ownable.sol";

// Contract definition for the FriendTech token with ERC721 Enumerable and Ownable features
contract FriendTech is ERC721Enumerable, Ownable {
    // Mapping to store the price of shares for each user
    mapping(address => uint256) private sharesPrice;
    // Mapping to store the total supply of shares for each user
    mapping(address => uint256) private totalSharesSupply;
    // Mapping to track user's shares balance with other users
    mapping(address => mapping(address => uint256)) private userSharesBalance;

    // Event triggered when a user sets the price of their shares
    event SharesPriceSet(address indexed user, uint256 price);
    // Event triggered when a user sets their total supply of shares
    event SharesSupplySet(address indexed user, uint256 supply);
    // Event triggered when shares are bought from another user
    event SharesBought(address indexed buyer, address indexed seller, uint256 amount);
    // Event triggered when shares are sold to another user
    event SharesSold(address indexed seller, address indexed buyer, uint256 amount);
    // Event triggered when shares are transferred to another user
    event SharesTransferred(address indexed from, address indexed to, uint256 amount);

    // Constructor for initializing the token with name "FriendTech" and symbol "FTCH"
    constructor() ERC721("FriendTech", "FTCH") {}

    // Function to allow users to set the price of their shares
    function setSharesPrice(uint256 price) public {
        sharesPrice[msg.sender] = price; // Set the price for the caller's shares
        emit SharesPriceSet(msg.sender, price); // Emit an event indicating the price was set
    }

    // Function to allow users to set their total supply of shares
    function setSharesSupply(uint256 supply) public {
        totalSharesSupply[msg.sender] = supply; // Set the total supply for the caller's shares
        emit SharesSupplySet(msg.sender, supply); // Emit an event indicating the supply was set
    }

    // Function for users to buy shares from another user
    function buyShares(address seller, uint256 amount) public payable {
        uint256 price = sharesPrice[seller];
        require(price > 0, "Seller has not set the price for the shares");
        require(msg.value >= price * amount, "Insufficient Ether sent");

        userSharesBalance[seller][msg.sender] += amount; // Update buyer's balance of shares from seller
        userSharesBalance[msg.sender][seller] -= amount; // Update seller's balance of shares to buyer

        payable(seller).transfer(msg.value); // Transfer the Ether sent to the seller

        emit SharesBought(msg.sender, seller, amount); // Emit an event for the shares bought
    }

    // Function for users to sell shares to another user
    function sellShares(address buyer, uint256 amount) public {
        uint256 price = sharesPrice[msg.sender];
        require(price > 0, "You have not set the price for your shares");
        
        require(userSharesBalance[msg.sender][msg.sender] >= amount, "Insufficient shares balance");

        userSharesBalance[buyer][msg.sender] += amount; // Update buyer's balance of shares from seller
        userSharesBalance[msg.sender][buyer] -= amount; // Update seller's balance of shares to buyer

        emit SharesSold(msg.sender, buyer, amount); // Emit an event for the shares sold
    }

    // Function for users to transfer shares to another user
    function transferShares(address to, uint256 amount) public {
        require(userSharesBalance[msg.sender][msg.sender] >= amount, "Insufficient shares balance");

        userSharesBalance[to][msg.sender] += amount; // Update the recipient's balance with shares
        userSharesBalance[msg.sender][to] -= amount; // Update the sender's balance by sending shares

        emit SharesTransferred(msg.sender, to, amount); // Emit an event for shares transferred
    }
}