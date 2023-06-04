// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract PaintingCar { 
    struct Car {
        uint id_car; 
        string color;
        string brand;
    }

    struct Masters {
        string surname; 
        uint score;
    }

    struct Registration {
        string date_reg;
        bool paint;
        bool addedOnPaint;
        uint price;
        string color;  
    }


    mapping (address => Car[]) _cars;
    mapping (address => Masters) _masters;
    mapping (uint => Registration) _regs; 
    address admin = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;

    constructor() {
        _cars[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4].push(Car(1, "black", "Mazda"));
        _cars[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4].push(Car(2, "white", "Toyota"));
        _masters[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = (Masters("Logov", 12));
        _masters[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = (Masters("Ratov", 15));
        _regs[1] = Registration("2020-10-15", false, false, 0, "none");
    }

    function addNewCar(address _owner, uint _id_car, string memory _color, string memory _brand) public {
        require(msg.sender == admin, "u aren't an admin");
        require(checkCar(_owner, _id_car) == false, "There's already a car under this id");
        _cars[_owner].push(Car(_id_car, _color, _brand));
    }

    // проверка на существование машины
    function checkCar (address _owner, uint _id_car) public view returns (bool) {
        for (uint i = 0; i < _cars[_owner].length; i++){
            if (_cars[_owner][i].id_car == _id_car){
                return true;
            }
        }
        return false;
    }

    // Проверка на существование мастера
    function checkMaster(address _master) public view returns(bool) {
        if (_masters[_master].score > 0) {
            return true;
        } else {
            return false;
        }
    }
    // Проверка стоит ли машина на покраске
    function checkCarOnPaint(uint _id_reg) public view returns (bool) {
        if (_regs[_id_reg].addedOnPaint == false) {
            return true;
        } else {
            return false;
        }
    }

    function regCar(uint _id_reg, string memory _date) public {
        require(checkMaster(msg.sender) == true, "u aren't a master");
        _regs[_id_reg] = Registration (_date, false, false, 0, "none");
    }

    function regCarForPainting(uint _id_reg, string memory _date) public {
        require(checkMaster(msg.sender) == true, "u aren't a master");
        require(checkCarOnPaint(_id_reg) == true, "car already on painting");
        _regs[_id_reg].addedOnPaint = true;
    }

    function priceEstimate(uint _id_reg) public {
        require(checkMaster(msg.sender) == true, "u aren't a master");
        require(_regs[_id_reg].price == 0, "price already ertimate");
        _regs[_id_reg].price = 5000;
    }

    function paintCar(bool agreement, uint _id_reg, string memory _color) public payable {
        require(checkMaster(msg.sender) == true, "u aren't a master");
        require(_regs[_id_reg].price > 0, "price isn't estimated");
        require(_regs[_id_reg].paint == false, "car already painted");
        require(_regs[_id_reg].addedOnPaint == true, "the car isn't being painted");
        require(_regs[_id_reg].color == "none", "the car already painted");
        _regs[_id_reg].color = _color;
        _regs[_id_reg].paint = true;
    }

    function transferMoneyToContract(uint _id_reg, bool consent, uint _id_car) public payable {
        require(consent == true);
        require(checkCar(msg.sender, _id_car) == true);
        require(msg.value >= _regs[_id_reg].price*10**18);
    }

    function transferMoneyToMaster(uint _id_car, uint _id_reg) public payable {
        require(checkCar(msg.sender, _id_car) == true);
        payable (msg.sender).transfer(_regs[_id_reg].price*10*18);
    }
}
