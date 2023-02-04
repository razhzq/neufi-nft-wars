const war = artifacts.require("NFTWarV2");



module.exports = async function(deployer) {
    await deployer.deploy(war, 9464);
}