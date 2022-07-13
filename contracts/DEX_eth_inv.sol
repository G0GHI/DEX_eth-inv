// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title DEX_eth_inv
 * @notice the contract that will stor the three main function -- land, buy and sell
 * @author GOGHI
 */

contract DEX_eth_inv {
    mapping(address => uint256) public investedBalanceOf;

    AggregatorV3Interface internal ethPriceFeed;
    IERC20 public ethToken;
    IERC20 public invToken;
    address[] investors;

    constructor(address _ethTokenAddress, address _invTokenAddress) {
        ethPriceFeed = AggregatorV3Interface(
            0x9326BFA02ADD2366b30bacB125260Af641031331
        ); // for now I will use the kovan testnet priceFeed
        ethToken = IERC20(_ethTokenAddress);
        invToken = IERC20(_invTokenAddress);
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
        investedBalanceOf[msg.sender] += _amount;
    }

    /**
     * TODO I need to check the decimal of ethPrice, transaction fee
     * @dev takes ETH from the buyer, calculates the amount of INV to return based on the AMM algorithm and returns INV
     * @param _amount the amount of eth that a buyer is spending to buy INV
     */

    function buy(uint256 _amount) public isAmountAllowed(_amount) {
        ethToken.transferFrom(msg.sender, address(this), _amount);

        uint256 ethPrice = getEthPrice();
        uint256 liquidityPoolEthBalance = ethToken.balanceOf(address.this);
        uint256 liquidityPoolInvBalance = invToken.balanceOf(address.this);
        uint256 liquidityPoolTotal = (ethPrice * liquidityPoolEthBalance)**2;
        uint256 newAmountOfEthValue = ethPrice *
            (liquidityPoolEthBalance + _amount);
        uint256 amountOfInvToReturn = liquidityPoolInvBalance -
            (liquidityPoolTotal / newAmountOfEthValue);

        invToken.transfer(msg.sender, amountOfInvToReturn);
    }

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

    /**
     * @dev function that connects to the chainlink oracle and returns the current eth price
     */

    function getEthPrice() internal view returns (uint256) {
        (, int256 price, , , ) = ethPriceFeed.latestRoundData();
        return uint256(price);
    }
}
