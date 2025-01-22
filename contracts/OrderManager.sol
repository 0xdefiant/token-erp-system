// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ProductManager.sol";

contract OrderManager {
    struct Order {
        uint id;
        uint productId;
        uint quantity;
        address buyer;
        address seller;
    }

    struct Supplier {
        address supplierAddress;
        string name;
    }

    enum OrderStatus {
        Pending,
        Shipped,
        Delivered,
        Cancelled
    }

    mapping(uint => Order) public orders;
    mapping(address => Supplier) public suppliers;
    mapping(uint => OrderStatus) public orderStatuses;
    uint public orderCounter;
    address public productManagerAddress;

    ProductManager public productManager;

    function initialize(address _productManagerAddress) public {
        require(productManagerAddress == address(0), "Already initialized");
        productManagerAddress = _productManagerAddress;
    }

    // Constructor to set the address of the ProductManager contract
    constructor(address _productManagerAddress) {
        productManager = ProductManager(_productManagerAddress);
    }

    // Events
    event OrderCreated(uint indexed orderId, uint productId, uint quantity, address buyer, address seller);
    event OrderStatusChanged(uint indexed orderId, OrderStatus newStatus);
    event SupplierAdded(address indexed supplierAddress, string name);

    // Function to create an order
    function createOrder(uint _productId, uint _quantity, address _buyer) public {
        (uint id, , uint quantity, ) = productManager.getProduct(_productId);
        require(id != 0, "Product does not exist");
        require(quantity >= _quantity, "Not enough in stock");
        
        orders[orderCounter] = Order({
            id: orderCounter,
            productId: _productId,
            quantity: _quantity,
            buyer: _buyer,
            seller: msg.sender
        });
        orderStatuses[orderCounter] = OrderStatus.Pending;
        
        orderCounter++;
        emit OrderCreated(orderCounter - 1, _productId, _quantity, _buyer, msg.sender);
    }

    // Function to add a supplier
    function addSupplier(address _supplierAddress, string memory _name) public {
        suppliers[_supplierAddress] = Supplier({
            supplierAddress: _supplierAddress,
            name: _name
        });
        emit SupplierAdded(_supplierAddress, _name);
    }

    // Function to update order status (simplified example)
    function updateOrderStatus(uint _orderId, OrderStatus _newStatus) public {
        require(orders[_orderId].id != 0, "Order does not exist");
        orderStatuses[_orderId] = _newStatus;
        emit OrderStatusChanged(_orderId, _newStatus);
    }
}