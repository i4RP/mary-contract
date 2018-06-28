pragma solidity ^0.4.19;


function propose(address _address) external payable {
    _address.transfer(msg.value)
}
