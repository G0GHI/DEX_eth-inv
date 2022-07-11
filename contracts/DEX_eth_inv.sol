// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title DEX_eth_inv
 * @notice the contract that will stor the three main function -- land, buy and sell
 * @author GOGHI
 */

contract DEX_eth_inv {
    mapping(address => uint256) investedBalanceOf;

    IERC20 public ethToken;
    address[] investors;

    constructor(address _ethTokenAddress) {
        ethToken = IERC20(_ethTokenAddress);
    }

    /**
     * @dev check if the amount is greater than 0 and if the investor can afford it
     * @param _amount the amount that the investors is investing
     */

    modifier isAmountAllowed(uint256 _amount) {
        require(_amount > 0);
        require(ethToken.balanceOf(msg.sender) >= _amount);
        _;
    }

    /**
     * @dev stores the investors money
     * @param _amount the amount of ETH someone wants to invest
     */

    function invest(uint256 _amount) public isAmountAllowed(_amount) {
        ethToken.transferFrom(msg.sender, address(this), _amount);
        if (checkIfInvestorNotInList(msg.sender)) {
            investors.push(msg.sender);
        }
        investedBalanceOf(msg.sender) += _amount;
    }

    /**
     * @dev takes ETH from the buyer and returns INV
     */

    function buy() public {}

    /**
     * @dev takes INV from the buyer and returns ETH
     */

    function sell() public {}

    /**
     * @dev function that checks if an investor already invested before
     * @param _investor the address of the investor
     */

    function checkIfInvestorNotInList(address _investor)
        internal
        returns (bool)
    {
        for (uint256 i; i < investors.length; i++) {
            if (investors[i] == _investor) {
                return false;
            }
        }
        return true;
    }
}
