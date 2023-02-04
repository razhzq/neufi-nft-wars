// contract without Chainlink VRF 

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTWarV1 is ERC1155 { 

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
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

    constructor() ERC1155("") {
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
             
       
    }

    function result(uint attackRatio) public {
        address counterPlayer = Battle[msg.sender].counterPlayer;
        if(Battle[counterPlayer].counterPlayer != msg.sender) revert ChallengeNotTaken(); //check if counter player has submitted NFTid for battle

        address _playerA = msg.sender;
        address _playerB = Battle[msg.sender].counterPlayer;

        // if attack ratio is more than 50, player A wins
        if(attackRatio > 50) {  
            _burn(_playerB, Battle[_playerB].nftIdAttacker, 1);   // burn nft of player B
            delete ownerOfNFT[Battle[_playerB].nftIdAttacker];
            KillCount[_playerA][Battle[_playerA].nftIdAttacker] = KillCount[_playerA][Battle[_playerA].nftIdAttacker] + 1;   // add killCount 
        } else {       // else Player B wins
            _burn(_playerA, Battle[_playerA].nftIdAttacker, 1);    // burn nft of player A
            delete ownerOfNFT[Battle[_playerA].nftIdAttacker];
            KillCount[_playerB][Battle[_playerB].nftIdAttacker] = KillCount[_playerB][Battle[_playerB].nftIdAttacker] + 1;   // add killCount
        }




    }


    function idArray() internal {
        for(uint i=1; i < 101; i++) {
           tokenIdList.push(i);
           amount.push(1);
        }
    }

}