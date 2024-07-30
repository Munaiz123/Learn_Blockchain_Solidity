// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MIN_USD = 1 * 1e16;
    address[] public funders;
    
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;

    constructor(){
        i_owner = msg.sender;
    }


    function fund() public payable  {
        // Allow users to send a min $1 amount
        require(msg.value.getConversionRate() >= MIN_USD, "Didnt send enough ETH "); // 1e18 wei = 1 eth - use eth-converter.com
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
        
    }

    function withdraw() public onlyOwner {
        //require(msg.sender == i_owner, "Must be owner to call this function"); // look at modifier

        for(uint i = 0; i < funders.length; i++){
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;   
        }
        funders = new address[](0); // reset array
        
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    modifier onlyOwner(){
        // require(msg.sender == i_owner, "Sender is not owner");
        if(msg.sender != i_owner){ revert NotOwner();}
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    // I. gas efficiency - immutable + constants
    // II. Custom errors - 
    /*  Declare error before contract on top 
        and use if() statements instead of require().
        if() statement is more gas efficient
    */
    // III. msg.sender - 1.transfer, 2.send, 3.call
    /*
        // 1.transfer - auto reverts if fails
        // msg.sender - address type
        // payable(msg.sender) - payable address type
        payable(msg.sender).transfer(address(this).balance);

        // 2.send - returns boolean
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send Failed");

        //3.call - lower level command
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    */
    // IV. Fallback + Receive:
    /*
        What happens if someone sends this contract ETH without calling the fund function
        OR what happens if someone calls a function that doesn't exist

        See FallbackExample.sol

    */


}