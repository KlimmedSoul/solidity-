// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

pragma experimental ABIEncoderV2;

contract SellApartment {
    address admin = 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678;
    address client;

    struct Estate {
        uint id;
        address owner; 
        uint square;
        uint lifetime;
    }

    struct Sale {
        uint id;
        uint price; 
        bool onSale;
        address statusGetClient;
        bool transferred;
        uint amountInSeconds;
    }

    Estate[] public estates;
    Sale[] public sales;


    constructor() {
        estates.push(Estate(0, 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 50, 7));
        sales.push(Sale(0, 50, true, address(0), false, 300));
    }


    function getOnSale(uint _id, uint _price, uint _amountInSeconds) public  {
        require(estates[_id].owner == msg.sender);
        require(sales[_id].onSale == false);
        sales.push(Sale(_id, _price, true, address(0), false,_amountInSeconds));
    }

    function addNewEstate(address _owner, uint _square, uint _lifetime) public {
        require(msg.sender == admin);
        estates.push(Estate(estates.length, _owner, _square, _lifetime));
    }

    function getMoneyToContract(uint _id) public payable {
        require(msg.sender != estates[_id].owner);
        require(sales[_id].onSale == true);
        require(msg.value == (sales[_id].price * 10**18));
        client = msg.sender;
        sales[_id].statusGetClient = msg.sender;
        sales[_id].transferred = true;
    }


    function removeFromSale(uint _id) public {
        require(msg.sender == estates[_id].owner);
        require(sales[_id].onSale == true);
        sales[_id].onSale = false;
    }

    function addFromSale(uint _id) public {
        require(msg.sender == estates[_id].owner);
        require(sales[_id].onSale == false);
        sales[_id].onSale = true;
    }

    function cancellationOfSale(uint _id) public payable {
        require(msg.sender == estates[_id].owner);
        require(sales[_id].onSale == false);
        sales[_id].onSale = false;
        if (sales[_id].transferred == true) {
            payable(client).transfer(sales[_id].price * 10**18);
        }
    }


    function getMoneyToOwner(uint _id) public payable {
        require(msg.sender != estates[_id].owner);
        require(sales[_id].amountInSeconds > 0);
        payable(estates[_id].owner).transfer(sales[_id].price);
        estates[_id].owner = msg.sender;
        sales[_id].onSale = false; 
        sales[_id].price = 0;
        sales[_id].amountInSeconds = 0;
    }


    function checkEstate() public view returns (Estate[] memory){
        return estates;
    }

    function checkSales() public view returns (Sale[] memory){
        return sales;
    }
}
