// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    function getPrice() internal view returns (uint256){
        //address - 0x7bAC85A8a13A4BcD8abb3eB7d6b4d632c5a57676 - polygon matic main
        //address - 0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910 - sepolia eth test
        //ABI
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x1a81afB8146aeFfCFc5E50e8479e826E7D55b910);
        (,int256 answer,,,) = priceFeed.latestRoundData();

        return uint256(answer * 1e10);
    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountUSD = (ethPrice * ethAmount) / 1e18;
        return  ethAmountUSD;
    }
    
}