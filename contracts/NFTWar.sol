pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


contract NFTWar is ERC1155, VRFConsumerBaseV2 {

    VRFCoordinatorV2Interface coordinator;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address coordinatorAddress = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
    uint64 s_subscriptionId;
    uint32 callbackGasLimit = 200000;
    uint16 requestConfirmations = 3;
    
    uint[] private tokenIdList;
    uint[] private amount;


    struct Attack {
        address counterPlayer;
        uint nftIdAttacker;
    }

    mapping(address => Attack) public Battle;
    mapping(address => mapping(uint => uint)) public KillCount;

    error ChallengeNotTaken();

    constructor(uint64 _subscriptionId) ERC1155("") VRFConsumerBaseV2(coordinatorAddress) {
        coordinator = VRFCoordinatorV2Interface(coordinatorAddress);
        s_subscriptionId = _subscriptionId;
        idArray();
       _mintBatch(address(this), tokenIdList, amount, "");
    }
    function mint() public returns (uint) {
        _tokenIds.increment();
        uint nftTokenId = _tokenIds.current();
       _safeTransferFrom(address(this), msg.sender, nftTokenId, 1, "");
       return nftTokenId;

    }

    function battle(address counterPlayer, uint _nftId) public {
        require(counterPlayer != msg.sender);
        Battle[msg.sender] = Attack(counterPlayer, _nftId);
       
    }

    function result() public {
        address counterPlayer = Battle[msg.sender].counterPlayer;
        if(Battle[counterPlayer].counterPlayer != msg.sender) revert ChallengeNotTaken();

        address _playerA = msg.sender;
        address _playerB = Battle[msg.sender].counterPlayer;

    }

    function generateRandomNumber() public view returns (uint256) {
        uint256 seed = getRandomSeed();
        return uint256(uint64(sha256(abi.encodePacked(seed))) % 100);
    }

    function idArray() internal {
        for(uint i=1; i < 101; i++) {
           tokenIdList.push(i);
           amount.push(1);
        }
    }

}