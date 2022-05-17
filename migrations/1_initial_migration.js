const NFTLendingV1 = artifacts.require("NFTLendingV1");
const MyNFT = artifacts.require("MyNFT");

module.exports = async function (deployer) {
  await deployer.deploy(NFTLendingV1);
  await deployer.deploy(MyNFT);
};