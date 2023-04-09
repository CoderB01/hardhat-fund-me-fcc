// SPDX-License-Identifier: MIT
// Pragma first
pragma solidity ^0.8.7;

// Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

// Error codes
error Fundme__NotOwner();

// Interface, libararies, Contracts

/**
 * @title A contract for crowd funding
 * @author Benatei Tamarau-ebi
 * @notice This contract is to demo a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    // Type declarations
    using PriceConverter for uint256; // Using the priceconverter library for uint256

    // State variables
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;
    uint256 public constant MINIMUM_USD = 50 * 1e18; // you have to multiply by 1e18 because eth works with gwei and gwei got 18 zeros
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;

    // Modifier
    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Only owner can call this function");
        if (msg.sender != i_owner) revert("Fundme__NotOwner()");
        _;
    }

    // constructor
    // receive function (if exists)
    // fallback function (if exists)
    // external
    // public
    // internal
    // private

    constructor(address s_priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(s_priceFeedAddress);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * @notice This function funds the contract
     * @dev This implements price feeds as our library
     */
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough funds"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    // Withdraw Funds
    function withdraw() public onlyOwner {
        // loop through the s_funders array and set the value of each funder to 0
        for (
            uint256 fundersIndex = 0;
            fundersIndex < s_funders.length;
            fundersIndex++
        ) {
            address funder = s_funders[fundersIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // Reset the s_funders array
        s_funders = new address[](0);

        // Withdraw funds from the contract
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!callSuccess) revert("Fundme__NotOwner()");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;

        for (
            uint256 fundersIndex = 0;
            fundersIndex < funders.length;
            fundersIndex++
        ) {
            address funder = funders[fundersIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);
        (bool success, ) = payable(i_owner).call{value: address(this).balance}(
            ""
        );
        require(success);
    }

    // pure / view functions

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunders(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getaddressToAmountFunded(
        address index
    ) public view returns (uint256) {
        return s_addressToAmountFunded[index];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
