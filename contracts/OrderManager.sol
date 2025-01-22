// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ProductManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OrderManager {
    // Defines the structure for an Order, storing basic order information.
    struct Order {
        uint id;         // Unique identifier for the order
        uint productId;  // ID of the product being ordered
        uint quantity;   // Quantity of the product ordered
        address buyer;   // Address of the buyer
        address seller;  // Address of the seller
    }

    // Defines the structure for a Supplier, storing supplier details.
    struct Supplier {
        address supplierAddress; // Address of the supplier
        string name;             // Name of the supplier
    }

    // Enumeration for different statuses of an order.
    enum OrderStatus {
        Pending,
        Shipped,
        Delivered,
        Cancelled
    }

    // Mapping to store orders by their ID.
    mapping(uint => Order) public orders;
    // Mapping to store supplier information by their address.
    mapping(address => Supplier) public suppliers;
    // Mapping to store the status of each order by order ID.
    mapping(uint => OrderStatus) public orderStatuses;
    // Counter to generate unique IDs for new orders.
    uint public orderCounter;
    // Address of the ProductManager contract, used for initialization.
    address public productManagerAddress;

    // Instance of the ProductManager contract for interaction.
    ProductManager public productManager;
    IERC20 public token;

    // Function to initialize the contract with the ProductManager's address. 
    // This can be used if the address isn't known at deployment time.
    function initialize(address _productManagerAddress) public {
        require(productManagerAddress == address(0), "Already initialized");
        // Ensures that the contract can only be initialized once.
        productManagerAddress = _productManagerAddress;
    }

    // Constructor to set the address of the ProductManager contract when the contract is deployed.
    constructor(address _productManagerAddress, address _tokenAddress) {
        productManager = ProductManager(_productManagerAddress);
        token = IERC20(_tokenAddress);
    }

    // Events for logging changes in the contract state.
    event SaleCompleted(uint indexed productId, string name, uint quantity, address buyer, uint totalPrice);
    event OrderStatusChanged(uint indexed orderId, OrderStatus newStatus);
    event SupplierAdded(address indexed supplierAddress, string name);
    event Claimed(address indexed claimer, uint256 amount);


    // Function to execute a sale:
    function executeSale(uint _productId, uint _quantity) public payable {
        // Fetch product details from ProductManager
        (uint id, string memory name, uint availableQuantity, uint price) = productManager.getProduct(_productId);
        
        // Check if the product exists
        require(id != 0, "Product does not exist");
        // Check if there's enough stock
        require(availableQuantity >= _quantity, "Not enough stock");
        // Check if the sent Ether is sufficient for the purchase
        require(msg.value >= price * _quantity, "Insufficient payment sent");

        // Transfer ownership of the product
        // Assuming you have a method in ProductManager to transfer or mark ownership
        productManager.transferProduct(_productId, _quantity, msg.sender);

        // Emit an event for the sale
        emit SaleCompleted(_productId, name, _quantity, msg.sender, msg.value);

        // Optionally update the stock in ProductManager
        productManager.removeProduct(_productId);
    }

    // Function to add a new supplier:
    function addSupplier(address _supplierAddress, string memory _name) public {
        // Adds the supplier to the 'suppliers' mapping.
        suppliers[_supplierAddress] = Supplier({
            supplierAddress: _supplierAddress,
            name: _name
        });
        // Emits an event to log the addition of a supplier.
        emit SupplierAdded(_supplierAddress, _name);
    }

    // Function to update the status of an order:
    function updateOrderStatus(uint _orderId, OrderStatus _newStatus) public {
        // Checks if the order exists before updating its status.
        require(orders[_orderId].id != 0, "Order does not exist");
        orderStatuses[_orderId] = _newStatus;
        // Emits an event to log the status change of the order.
        emit OrderStatusChanged(_orderId, _newStatus);
    }

    // Function to claim funds based on token holding
    function claim() public {
        uint256 totalSupply = token.totalSupply();
        require(totalSupply > 0, "Token has no supply");

        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds to claim");

        uint256 userBalance = token.balanceOf(msg.sender);
        require(userBalance > 0, "You do not hold any tokens");

        // Calculate the share of the user based on their token holding
        uint256 share = (contractBalance * userBalance) / totalSupply;
        
        // Ensure the share calculation doesn't result in 0 due to rounding or very small balances
        require(share > 0, "Your share is too small to claim");

        // Transfer the calculated share to the user
        payable(msg.sender).transfer(share);
        
        emit Claimed(msg.sender, share);
    }
}