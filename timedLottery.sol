// SPDX-License-Identifier: UNLICENSED
// Ashutosh Karanam

pragma solidity >= 0.5.0 < 0.9.0;

contract Lottery
{
    address public manager;                             //change on line 49
    address payable paymentAdd = payable(manager);
    address payable[] public participants;
    uint weiVal = 1000000000000000000;                  //change on line 34
    uint minParticipants = 3;                           //change on line 39
    uint feeAmt = 1000000000000000;                     //change on line 44     //ratio of wei in balance to send to winner
    uint startTime = block.timestamp;
    uint eventLength = 604800;                          //change on line 55     //604800 is number of seconds in a week

    constructor() 
    {
        manager = msg.sender;
    }

    receive() external payable
    {
        require(msg.value == weiVal);
        participants.push(payable(msg.sender));
    }

    modifier onlyManager 
    {
        require(msg.sender == manager);
        _;
    }

    function newWeiVal(uint _newWeiVal) public onlyManager
    {
        weiVal = _newWeiVal;      
    }

    function newMinParticipants(uint _newMinParticipants) public onlyManager
    {
        minParticipants = _newMinParticipants;      
    }

    function newFeeAmt(uint _newFeeAmt) public onlyManager
    {
        feeAmt = _newFeeAmt;
    }

    function changeManager(address _newManager) public onlyManager
    {
        manager = _newManager;    
        paymentAdd = payable(manager);  
    }

    function newEventLength(uint _newEventLength) private onlyManager
    {
        eventLength = _newEventLength;
    }

    function getBalance() public view onlyManager returns(uint)
    {
        return address(this).balance;
    }

    function managersFee() internal onlyManager returns(uint)    
    {
        uint totalAmt = getBalance();
        require(feeAmt <= totalAmt);
        uint fee = totalAmt*feeAmt/1000000000000000000;
        return fee;
    }

    function random() internal onlyManager returns(uint)
    {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }

    modifier timelyExecution
    {
        uint nowTime = block.timestamp;
        require(nowTime == startTime + eventLength);
        _;
    }

    function selectWinner() public payable timelyExecution onlyManager
    {
        //choose winner from participant
        require(participants.length >= minParticipants);
        uint r = random();
        address payable winner;
        uint index = r % participants.length;
        winner = participants[index];

        //reward winner
        uint fee = managersFee();
        paymentAdd.transfer(fee);
        winner.transfer(getBalance());

        //reset the participants dynamic array 
        participants = new address payable[](0);
        uint nowTime = block.timestamp;
        startTime = nowTime;
    }

}
