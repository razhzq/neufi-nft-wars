const NFTWar = artifacts.require("NFTWarV1");

contract("NFTWar", (accounts) => {
    it("contract should have 100 distinct token", async () => {
        const NFTWarInstance = await NFTWar.deployed();
        // some logic to check tokens in NFTWar
        for(i=0; i < 100; i++) {
            const balance = await NFTWarInstance.balanceOf(NFTWarInstance.address, i).call(accounts[0]);
            assert.equal(balance.valueOf(), 1, "token not exist");
        }
        // assert to check the tokens amount equal 100
    });

    it("user receive 1 token when mint", async () => {
        const NFTWarInstance = await NFTWar.deployed();
        const nftId =  await NFTWarInstance.mint.call(accounts[0]);
        const balance = await NFTWarInstance.balanceOf(accounts[0], nftId);

        assert.equal(balance.valueOf(), 1, "NFT not received")
        

    })

    it("battle success", async () => {
        const NFTWarInstance = await NFTWar.deployed();
        const nftId1 =  await NFTWarInstance.mint.call(accounts[0]); 
        const nftId2 =  await NFTWarInstance.mint.call(accounts[1]);

        const attackRatio = 60; // player 0 wins because attack ratio > 50
        const battleResult = await NFTWarInstance.result(attackRatio).call(accounts[0]);
        const nftOwner = await NFTWarInstance.ownerOfNFT(nftId2).call(accounts[0]);
        
        assert.equal(nftOwner, 0, "nft has been burned")
        


    })
    

})
