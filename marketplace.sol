// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract eCommerceMarketplace{

    //enum to define the order status
    enum OrderStatus {Ordered, Shipped, Delivered, Cancelled}

    //struct to represent the product
    struct Product {
        uint id;
        string name;
        uint price;   //price in wei
        address payable seller;
        bool isAvailable;
    }

    //struct to represent the order
    struct Order{
        uint orderId;
        uint productId;
        address buyer;
        OrderStatus status;
    }

    //state variables
    mapping (uint => Product) public products;  //mapping of products by product id
    mapping (uint => Order) public orders;  //mapping of orders by order id
    uint public productCount;      //counter for products
    uint public orderCount;        //counter for orders
    address public platformOwner;  //platform owner to handle fees

    //event declarations
    event ProductListed (uint id, string name, uint price, address seller);
    event ProductPurchase (uint orderId, uint productId, address buyer, OrderStatus status);
    event ProductShipped (uint productId);
    event ProductDelivered (uint productId);
    event OrderCancelled (uint orderId);


    //modifier to restrict actions to the product seller
    modifier onlySeller(uint _productId)  {
        require (products[_productId].seller == msg.sender,"Only the seller can perform this action");
        _;
    }

    //modifier to restrict actions to the product buyer
    modifier onlyBuyer(uint _orderId)  {
        require (orders[_orderId].buyer == msg.sender,"Only the buyer can perform this action");
        _;
    }

    //set owner
    constructor () {
        platformOwner = msg.sender;
    }

    //function to list the product for sale
    function listProduct(string memory _name, uint _price) public {
        require (_price > 0 ,"Price must be greater than 0");

        productCount++;

        products[productCount] = Product (productCount , _name, _price, payable(msg.sender), true);

        emit ProductListed(productCount, _name, _price, msg.sender);

    }
    //function to buy the product
    function purchaseProduct(uint _productId) public payable {
        Product storage product = products[_productId];
        require (msg.value == product.price,"Invalid amount entered");
        require (product.isAvailable,"product is not available for purchase");

        orderCount++;
        orders[orderCount] = Order(orderCount, _productId, msg.sender, OrderStatus.Ordered);

        emit ProductPurchase(orderCount, _productId, msg.sender, OrderStatus.Ordered);
    }

}