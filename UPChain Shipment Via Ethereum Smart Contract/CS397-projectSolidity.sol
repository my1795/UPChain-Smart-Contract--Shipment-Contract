pragma solidity ^0.5.0;

contract UPChain  {
    address public owner;
    address public buyerAd;
    mapping(address => uint256) balances;
    Order private order;
    
    mapping(uint => Product) offeredProducts;
    uint public productCount;
    uint public orderedProductseq;

    struct Product{
       string productName;
       uint productPrice;
    }

    struct Order{
       uint orderNo;
       mapping(uint => Product) products;
    }

    modifier ownerMod  {
        require(owner == msg.sender);
        _;
    }

    modifier buyerMod {
        require(buyerAd == msg.sender);
        _;

    }
    
    constructor (address _buyerAd) public {
        buyerAd = _buyerAd;
        order = Order(1);
        owner = msg.sender;
    }

    function addProduct(string memory _productName,uint _productPrice) public ownerMod{
        offeredProducts[productCount] = Product(_productName,_productPrice);
        productCount++;
    }

    function queryProduct(uint _productCount) public view returns(string memory, uint){
       return (offeredProducts[_productCount].productName,offeredProducts[_productCount].productPrice);
    }   

    function addtoOrder(uint _productNo) public buyerMod{
        require(productCount>=_productNo, "non existing product");
        order.products[orderedProductseq] = offeredProducts[_productNo];
        orderedProductseq++;
    }

    function querryOrderedProduct(uint _orderedProductseq) public view buyerMod returns(string memory,uint){
        return(order.products[_orderedProductseq].productName,order.products[_orderedProductseq].productPrice);
    }

    function getOrderCost() public view returns(uint256 totalCost){
        for(uint i=0; i<orderedProductseq;i++){
            totalCost+= order.products[i].productPrice;
        }
    }
    //1000000000000000000
    function completeOrder() public payable buyerMod returns(string memory){
        uint totalPrice = getOrderCost();
        require(msg.value>=totalPrice);
        balances[buyerAd] += msg.value - totalPrice ;
        balances[owner] += totalPrice ;
        
    }

    function getContractBalance() view public returns(uint256){
        return address(this).balance;
    }

    
    function withdrawFunds() external {
        uint256 fund = balances[msg.sender];
        balances[msg.sender]=0;
        address payable receiver = msg.sender;
        require(receiver.send(fund),"Transaction can not be completed");
    }
    
    function getBalance() external view returns(uint256 balanceOf) {
        balanceOf = balances[msg.sender];
    }
    
}