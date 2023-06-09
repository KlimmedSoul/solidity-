// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

pragma experimental ABIEncoderV2;

contract chooseStarosta {

    struct Student {
        string fullName; 
        uint age; 
        uint role;
        bool vote;
        string group;
    }

    struct Vote {
        address[] newStarosta;
        string group; 
        uint startTime;
        uint amountInSeconds;
        bool active;
        uint[] golosa; 
    }

    uint flag = 0;
    mapping (address => Student) _students; 
    Vote[] _votes;
    address[] starosts;

    // role 1 - студент role - 2 староста

    address admin = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;

    constructor() {
        _students[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = (Student("Petrov Nikita", 17, 1, false, "ISIP"));
        _students[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = (Student("Kasat Kirill", 18, 1, false, "ISIP"));
        _students[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = (Student("Belyaev Semen", 17, 1, false, "KSK"));
        _students[0x617F2E2fD72FD9D5503197092aC168c91465E7f2] = (Student("Isaev Artem", 19, 1, false, "KSK"));
    }
    
    function getResultVote(uint _voteId, uint condId) public view returns (uint) {
        require(_votes[_voteId].active == false, "voting is still going on");
        return _votes[_voteId].golosa[condId];
    }

    function addCond(address cond, uint _idVote) public {
        require(msg.sender == admin, "u aren't admin");
        require(_votes[_idVote].active == true, "voting ended");
        for(uint i = 0; i < _votes.length; i++) {
            require(cond != _votes[_idVote].newStarosta[i], "cond already exsists");
        }
        _votes[_idVote].newStarosta.push(cond);
        _votes[_idVote].golosa.push(0);
    }

    function startVote(address firstCond, uint _endTime, string memory _group) public  {
        // require(msg.sender == admin, "u aren't admin");
        // require(_students[firstCond].age > 0, "stundet doesn't exist");
        // for(uint i = 0; i < _votes.length; i++){
        //     // require(keccak256(abi.encodePacked(_votes[i].group)) == keccak256(abi.encodePacked(_group)) && _votes[i].active == true, "voting already started in this group");
        // }
        address[] memory conds;
        uint[] memory golosa;
        conds[0] = firstCond;
        golosa[0] = 0;
        _votes.push(Vote(conds, _group, block.timestamp, _endTime, true, golosa));
    }

    function addStudent(address _newStudent, string memory _fullName, uint _age, string memory _group) public {
        require(msg.sender == admin, "u aren't admin");
        require(_students[_newStudent].age == 0, "this student already exists");
        require(_age < 50, "too big age");
        _students[_newStudent] = (Student(_fullName, _age, 1, false, _group));
    }

    function castVote(uint _voteId, uint _condId) public {
        require(_votes[_voteId].active == true, "vote already end");
        require(_students[msg.sender].vote == false, "u already vote");
        require(keccak256(abi.encodePacked(_students[msg.sender].group)) == keccak256(abi.encodePacked(_votes[_voteId].group)), "u aren't part of this group");
        require(_votes[_voteId].amountInSeconds + _votes[_voteId].startTime < block.timestamp, "vote already ended");
        _votes[_voteId].golosa[_condId]++;
        _students[msg.sender].vote = true;
    }


    function changeStarosta(uint _voteId) public  {
        address winner = _votes[_voteId].newStarosta[0];
        uint __golosa = _votes[_voteId].golosa[0];
        require(msg.sender == admin, "u aren't a admin");
        require(_votes[_voteId].amountInSeconds + _votes[_voteId].startTime < block.timestamp, "vote isn't ended");
        for(uint i = 0; i < _votes[_voteId].newStarosta.length; i++) {
            if (_votes[_voteId].golosa[i] > __golosa) {
                winner = _votes[_voteId].newStarosta[i];
            }
        }
        for(uint i = 0; i < starosts.length; i++) {
            if (keccak256(abi.encodePacked(_students[starosts[i]].group)) == keccak256(abi.encodePacked(_votes[_voteId].group))) {
                _students[starosts[i]].role = 1;
                starosts[i] = winner;
                flag++;
            }
        }
        if (flag == 0) {
            starosts.push(winner);
        }
        _students[winner].role = 2;
        _votes[_voteId].active = false;
        flag = 0; 
    }
}
