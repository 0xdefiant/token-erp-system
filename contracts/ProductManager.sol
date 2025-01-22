// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract ProductManager {
    // Defines a structure for a Product with fields for id, name, quantity, and price.
    struct Product {
        uint id;
        string name;
        uint quantity;
        uint price;
    }

    // Mapping to store products where the key is the product ID and the value is the Product struct.
    mapping(uint => Product) public products;
    mapping(uint => address) public productOwners;
    // Counter to keep track of the number of products added, used for validation or counting.
    uint public productCounter;

    // Events are used to signal that something has happened in the blockchain (like adding or removing a product).
    event ProductAdded(uint indexed productId, string name, uint quantity, uint price);
    event ProductRemoved(uint indexed productId);

    // Function to add a new product to the contract.
    function addProduct(uint _id, string memory _name, uint _quantity, uint _price) public {
        // Check if the product ID is unique before adding.
        require(products[_id].id == 0, "Product with this ID already exists");
        
        // Create and store a new Product in the mapping.
        products[_id] = Product({
            id: _id,
            name: _name,
            quantity: _quantity,
            price: _price
        });
        
        // Increment the product counter.
        productCounter++;
        // Emit an event to notify that a product has been added.
        emit ProductAdded(_id, _name, _quantity, _price);
    }

    // Function to transfer product ownership during a sale
    function transferProduct(uint _productId, uint _quantity, address _newOwner) public {
        // Check if the product exists
        require(products[_productId].id != 0, "Product does not exist");
        
        // Check if there's enough stock for the purchase
        require(products[_productId].quantity >= _quantity, "Insufficient stock available");

        // If this is the first time the product is being sold or if it's being split
        if (productOwners[_productId] == address(0) || _quantity < products[_productId].quantity) {
            // Partial sale or first sale scenario
            // Reduce quantity in stock
            products[_productId].quantity -= _quantity;
            
            // If selling all remaining stock, update ownership
            if (products[_productId].quantity == 0) {
                productOwners[_productId] = _newOwner;
            }
        } else {
            // If selling the entire product at once (no split)
            productOwners[_productId] = _newOwner;
            products[_productId].quantity = 0; // Make sure all stock is sold
        }
        
        // If you want to keep track of who owns what, you might want to extend this further
        // For simplicity, we're just updating the owner for the product ID
    }
    
    // Function to remove an existing product from the contract.
    function removeProduct(uint _id) public {
        // Check if the product exists before attempting to remove it.
        require(products[_id].id != 0, "Product does not exist");
        
        // Remove the product from the mapping by deleting it.
        delete products[_id];
        // Emit an event to notify that a product has been removed.
        emit ProductRemoved(_id);
    }

    // Function to retrieve product details, marked as 'view' which means it does not modify the contract state.
    function getProduct(uint _id) public view returns (uint, string memory, uint, uint) {
        // Load the product from the mapping into memory for faster access.
        Product memory product = products[_id];
        // Ensure the product exists before returning its details.
        require(product.id != 0, "Product does not exist");
        
        // Return the product details in the order: id, name, quantity, price.
        return (product.id, product.name, product.quantity, product.price);
    }
}