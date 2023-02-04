pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


contract NFTWarV2 is ERC1155, VRFConsumerBaseV2 {

    VRFCoordinatorV2Interface coordinator; 

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address coordinatorAddress = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D; // Goerli VRF Coordinator address
    uint64 s_subscriptionId;   // subID from vrf subscription
    uint32 callbackGasLimit = 200000;
    uint16 requestConfirmations = 3;  
    uint32 public numWords =  3;
    bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint256[] public s_randomWords;
    uint256 public s_requestId;
    
    uint[] private tokenIdList;
    uint[] private amount;


    struct Attack {
        address counterPlayer;
        uint nftIdAttacker;
    }


    mapping(uint => address) public ownerOfNFT;
    mapping(address => Attack) public Battle;
    mapping(address => mapping(uint => uint)) public KillCount;

    error ChallengeNotTaken();

    constructor(uint64 _subscriptionId) ERC1155("") VRFConsumerBaseV2(coordinatorAddress) {
        coordinator = VRFCoordinatorV2Interface(coordinatorAddress);
        s_subscriptionId = _subscriptionId;
        idArray();   // return array of id from 1 to 100
       _mintBatch(address(this), tokenIdList, amount, ""); // mint 100 token. 1 for each token ID
    }

    function mint() public returns (uint) {
        _tokenIds.increment();
        uint nftTokenId = _tokenIds.current();
       _safeTransferFrom(address(this), msg.sender, nftTokenId, 1, "");  // transfer 1 NFT from contract to msg.sender
       ownerOfNFT[nftTokenId] = msg.sender;
       return nftTokenId;

    }

    function battle(address counterPlayer, uint _nftId) public {
        require(counterPlayer != msg.sender);  // prevent user to play with self
        require(ownerOfNFT[_nftId] == msg.sender);   // check if NFT is owned by msg.sender
        Battle[msg.sender] = Attack(counterPlayer, _nftId);
             
                                                  
        if(Battle[counterPlayer].nftIdAttacker == 0) {  // check condition to only allow random number to be requested only once
            requestRandomWords();                      
        } 
       
    }

    // return 1 - player A wins / return 2 - player B wins
    function result() public returns(uint) {
        address counterPlayer = Battle[msg.sender].counterPlayer;
        if(Battle[counterPlayer].counterPlayer != msg.sender) revert ChallengeNotTaken(); //check if counter player has submitted NFTid for battle

        address _playerA = msg.sender;
        address _playerB = Battle[msg.sender].counterPlayer;

        uint attackRatio = (s_randomWords[0] % 100);  // random number in range of 100


        // if attack ratio is more than 50, player A wins
        if(attackRatio > 50) {  
            _burn(_playerB, Battle[_playerB].nftIdAttacker, 1);   // burn nft of player B
            delete ownerOfNFT[Battle[_playerB].nftIdAttacker];
            KillCount[_playerA][Battle[_playerA].nftIdAttacker] = KillCount[_playerA][Battle[_playerA].nftIdAttacker] + 1;   // add killCount 
            
            return 1;
        } else {       // else Player B wins
            _burn(_playerA, Battle[_playerA].nftIdAttacker, 1);    // burn nft of player A
            delete ownerOfNFT[Battle[_playerB].nftIdAttacker];
            KillCount[_playerB][Battle[_playerB].nftIdAttacker] = KillCount[_playerB][Battle[_playerB].nftIdAttacker] + 1;   // add killCount

            return 2;
        }




    }

    function requestRandomWords() private {
        s_requestId = coordinator.requestRandomWords(
                      keyHash,
                      s_subscriptionId,
                      requestConfirmations,
                      callbackGasLimit,
                      numWords
                );
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        s_randomWords = randomWords;
   }


    function idArray() private {
        for(uint i=1; i < 101; i++) {
           tokenIdList.push(i);
           amount.push(1);
        }
    }

}