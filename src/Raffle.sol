// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title A sample Raffle Contract
 * @author Krasimir Markov
 * @notice This contract is for creating  a sample raffle
 * @dev Implements Chainlink VRFv2
 */

contract Raffle is VRFConsumerBaseV2{
    error Raffle__NotEnoughETHSent();

    uint16 private constant REQUEST_CONFRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    event enteredRaffle(address indexed player);
    uint256 private s_lastTimeStamp;
    uint256 private i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    
   


    constructor(uint256 entranceFee, 
    uint256 interval, 
    address vrfCoordinator, 
    bytes32 gasLane, 
    uint64 subscriptionId, 
    uint32 callbackGasLimit)
    VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() public payable {
        // require(msg.value >= i_entranceFee,"Not enough ETH sent!");

        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughETHSent();
        }

        s_players.push(payable(msg.sender));

        emit enteredRaffle(msg.sender);
    }

    function pickWinner() external {
        // check to see if enough time has passed
        if ((block.timestamp - s_lastTimeStamp) < i_interval ) {
            revert();
        }

        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {

       
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
