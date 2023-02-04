pragma solidity ^0.8.15;


import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Rando is VRFConsumerBaseV2 {


  VRFCoordinatorV2Interface coordinator;
  
  uint64 s_subscriptionId;
  address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
  bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
  uint32 callbackGasLimit = 200000;
  uint16 requestConfirmations = 5;
  uint32 public numWords =  3;
  uint256[] public s_randomWords;
  uint256 public s_requestId;
  

  constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
    coordinator = VRFCoordinatorV2Interface(vrfCoordinator);
    s_subscriptionId = subscriptionId;
  }
  // Assumes the subscription is funded sufficiently.
  function requestRandomWords() external {
    // Will revert if subscription is not set and funded.
    s_requestId = coordinator.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
  }
  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    s_randomWords = randomWords;
  }
    

}