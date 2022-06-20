const token = artifacts.require('./BEP20Token.sol');
const faucet = artifacts.require('./MyFaucet.sol');
const lott = artifacts.require('./LotteryGame.sol');

module.exports = async function (deployer) {
	await deployer.deploy(token);
	console.log('tokenInstance.address :>> ', token.address);
	await deployer.deploy(faucet, token.address);
  await deployer.deploy(lott, token.address);
};
