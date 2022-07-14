// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title DEX_eth_inv
 * @notice the contract that will store the three main functions -- land, buy and sell
 * @author GOGHI
 */

contract DEX_eth_inv {
    mapping(address => uint256) public investedBalanceOf;

    AggregatorV3Interface internal ethPriceFeed;
    IERC20 public ethToken;
    IERC20 public invToken;
    address payable[] investors;
    uint256 investedEth;
    address payable myDevAddress;

    constructor(address _ethTokenAddress, address _invTokenAddress) {
        ethPriceFeed = AggregatorV3Interface(
            0x9326BFA02ADD2366b30bacB125260Af641031331
        ); // for now I will use the kovan testnet priceFeed
        ethToken = IERC20(_ethTokenAddress);
        invToken = IERC20(_invTokenAddress);
        myDevAddress = payable(0x93AB6B3d16e0b36A44F4E5663D5E0621EF6E03A4);
    }

    /**
     * @dev check if the amount is greater than 0 and if the investor can afford it
     * @param _amount the amount that the investor is investing
     */

    modifier isAmountAllowed(uint256 _amount) {
        require(_amount > 0, "Amount must be greater than 0!");
        require(
            ethToken.balanceOf(msg.sender) >= _amount,
            "You don't have enough eth in your wallet!"
        );
        _;
    }

    /**
     * @dev stores the investors money
     * @param _amount the amount of ETH someone wants to invest
     */

    function invest(uint256 _amount) public isAmountAllowed(_amount) {
        ethToken.transferFrom(msg.sender, address(this), _amount);
        if (checkIfInvestorNotInList(msg.sender)) {
            investors.push(payable(msg.sender));
        }
        investedBalanceOf[msg.sender] += _amount;
        investedEth += _amount;
    }

    /**
     * TODO I need to check the decimal of ethPrice
     * @dev takes ETH from the buyer, calculates the amount of INV to return based on the AMM algorithm and returns INV
     * than it takes a transaction fee that is 1%;
     * @param _amount the amount of eth that a buyer is spending to buy INV
     */

    function buy(uint256 _amount) public isAmountAllowed(_amount) {
        uint256 liquidityPoolEthBalance = ethToken.balanceOf(address(this));
        uint256 liquidityPoolInvBalance = invToken.balanceOf(address(this));
        uint256 liquidityPoolTotal = liquidityPoolEthBalance *
            liquidityPoolInvBalance;

        ethToken.transferFrom(msg.sender, address(this), _amount);

        uint256 newAmountOfEthToken = liquidityPoolEthBalance + _amount;
        uint256 amountOfInvToReturn = liquidityPoolInvBalance -
            (liquidityPoolTotal / newAmountOfEthToken);

        invToken.transfer(payable(msg.sender), amountOfInvToReturn);
        transactionFee(_amount);
    }

    /**
     * @dev takes INV from the buyer and returns ETH, no transaction fee here
     * @param _amount the amount of INV that someone wants to sell
     */

    function sell(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0!");
        require(
            invToken.balanceOf(msg.sender) >= _amount,
            "You don't have enought inv in your wallet!"
        );

        uint256 liquidityPoolEthBalance = ethToken.balanceOf(address(this));
        uint256 liquidityPoolInvBalance = invToken.balanceOf(address(this));
        uint256 liquidityPoolTotal = liquidityPoolEthBalance *
            liquidityPoolInvBalance;

        invToken.transferFrom(msg.sender, address(this), _amount);

        uint256 newAmountOfInvToken = liquidityPoolInvBalance + _amount;
        uint256 amountOfEthToReturn = liquidityPoolEthBalance -
            (liquidityPoolTotal / newAmountOfInvToken);

        ethToken.transfer(payable(msg.sender), amountOfEthToReturn);
    }

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

    /**
     * @dev takes 1% of the amount spended and it divides it between me(10% of the fee)
     * and the investors(they divide the 90% of the fee dependently on how much they invested)
     * @param _amount the amount that the buyers spended in eth
     */

    function transactionFee(uint256 _amount) internal {
        uint256 fee = _amount / 100;
        uint256 myReward = fee / 10;

        ethToken.transfer(myDevAddress, myReward);

        uint256 investorsReward = (fee / 10) * 9;
        uint256 x = investorsReward / (investedEth + (investorsReward / 100));
        for (uint256 i; i < investors.length; i++) {
            ethToken.transfer(
                investors[i],
                (x * investedBalanceOf[investors[i]])
            );
        }
    }
}
