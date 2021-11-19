const deploy = async () => {

  // Brings me the address and private key that is allowed to sign
  const [deployer] = await ethers.getSigners();
  console.log('Deploying the contract', deployer.address);


  // We create an instancec of the contract to deploy
  const PlatziPunks = await ethers.getContractFactory("PlatziPunks");
  // We created an instance of the deployed contract
  const deployed = await PlatziPunks.deploy(10000);
  console.log('PlatziPunks is deployed at:', deployed.address);
};

deploy().then(() => process.exit(0)).catch(error => {
  console.log(error);
  process.exit(1);
});
