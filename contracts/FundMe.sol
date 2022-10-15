// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    // Declarations
    using PriceConverter for uint256;

    // State variables
    address public immutable i_owner; // Address of the contracct owner
    // IMMUTABLE is optional but is used for gas optimization. i_owner convention
    uint256 public constant MINIMUM_USD = 5 * 10**18; // Min funding amount OR  (5 * 1e18)
    // changes USD50 to 5 to spend less from my balance

    address[] public funders; // Address list of those who provided funds
    mapping(address => uint256) public addressToAmountFunded; // Will be populated Later as a 2 dim array

    AggregatorV3Interface private priceFeed; // Interface to external service of a cchain link

    constructor(address priceFeedAddress) {
        // Loaded just once during deployment
        i_owner = msg.sender; // During deployment sender address is assigned to i_owner
        priceFeed = AggregatorV3Interface(priceFeedAddress); // Setting up price feed. priceFeedAddreee - what is this?
    }

    modifier onlyOwner() {
        //require(msg.sender==owner, "Sender is not owner");
        // but for gas efficiency we can implement error handling instead (see next line)
        // this is because string needs a lot of gas
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _; // means do the rest of the code.
        // If instruction is after this line then it will be executed after the main code
    }

    // Checked
    function fund() public payable {
        // Want to be able to set minimum amount in USD
        // How do we send ETH to the contract?

        require(
            msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
            "Didn't send enough"
        ); // 1e18 = 1 * 10 ** 18 = 1 ETH
        //what is reverting?
        //undo any action before and send remaining gas back

        addressToAmountFunded[msg.sender] += msg.value; // Update mapping
        funders.push(msg.sender); // Append to list of Funders
    }

    // Checked
    function getVersion() public view returns (uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        // ); // ETH/USD price feed address of Goerli Network.
        return priceFeed.version();
    }

    function withdraw() public onlyOwner {
        // onlyOwner decoration means that we need to apply modifier onlyOwner
        for (
            uint256 funderIndex = 0; // From the first funder index (in the list)
            funderIndex < funders.length; // Until end of list is reached
            funderIndex++ // Step by 1
        ) {
            address funder = funders[funderIndex]; // Get funder address
            addressToAmountFunded[funder] = 0; // Reset amount for this address
        }
        funders = new address[](0); // reset the list  of funders

        // to actually withdraw the funds
        // 3 ways to send: transfer; send; call. We will use call but the rest can be used (uncommented)

        //msg.sender - address
        //payable(msg.sender) - payable address
        //check it: solidity-by-example.org/sending-ether

        //transfer:
        //payable(msg.sender).transfer(address(this).balance);

        //send:
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send failed")
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // we will use call
        (bool callSuccess, ) = payable(msg.sender).call{ // get results of payable function
            value: address(this).balance
        }(""); // call is a low-level interface for sending a message to a contract.
        require(callSuccess, "Call failed");
    }

    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    //if someone just send funds we want fund() to process this txn:
    //min USD amount will be applied as it is a part of fund()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly
