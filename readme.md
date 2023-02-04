NFT Wars Documentation

NFTWar is an ERC1155 token standard which has a supply of 100. It allows player to battle with their NFT on a 1v1 battle.

Constructor
On deployment, 100 ERC1155 tokens will be minted to the contract with each of them having only 1 as its balance. This is done by the idArray() function which iterates the number 1 to 101 and passes it to _mintBatch function as the id[ ] parameter. 

Contract Flow

Player will mint the NFT with mint() function. NFT will be transferred from contract to the player 
Player A initiates battle by passing the address of the challenged player(Player B) and the token id of NFT that will be used to attack the challenged to battle() function.
Player B responds by passing address of Player A and token id of NFT that will be used to attack
Either of the player invoke result() function to get the result of the battle. 
If Attack ratio of player (msg.sender) is more than 50, the player win.
NFT of the loser will be burned and the kill count of NFT of the winner will be incremented by 1. 
