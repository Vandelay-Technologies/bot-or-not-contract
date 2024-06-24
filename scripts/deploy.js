async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const Game = await ethers.getContractFactory("Game");
  const game = await Game.deploy();

  console.log("Game contract deployed to:", game.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
