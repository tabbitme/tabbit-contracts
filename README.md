# ERC6551 TabbitTicket contracts

ERC6551 TabbitTicket contracts that allows users to mint, load balance and reemed git cards.

## Features

- Mint gift cards with a URL and a value
- Redeem gift cards for goods or services

## About 6551

For more information about ERC-6551 Non-fungible Token Bound Accounts you can read EIP [here](https://eips.ethereum.org/EIPS/eip-6551).

ERC-6551 is a proposed standard to enhance the functionality of ERC-721 tokens, also known as Non-Fungible Tokens (NFTs), by providing each NFT with its unique smart contract account.

In the context of real-world applications, this is like giving your character in a video game its wallet where it can own and manage assets or, as we propose in this project, a NFT gift card that holds its own balance and can be redeemed. Currently, ERC-721 tokens are unable to do this. ERC-6551 aims to solve this problem by creating unique smart contract accounts, referred to as "token bound accounts," for each ERC-721 token.

Here's how it works in simpler terms:

1. **Registry:** It serves as a one-stop-shop for creating new token bound accounts for any ERC-721 token. You can think of this registry as a factory that produces new wallets for each NFT.

2. **Token Bound Accounts:** These are like individual wallets for each NFT. They are owned by a single NFT, allowing the NFT to interact with the Ethereum blockchain, record transaction history, and own other on-chain assets like Ether or other tokens.

3. **Control:** The ownership of the token bound account is tied to the ownership of the ERC-721 token. This means if you own the NFT, you also control its associated token bound account.

4. **Compatibility:** The proposal is designed to be backward compatible with existing ERC-721 tokens and infrastructure. This means that existing NFTs can be updated to have token bound accounts without requiring changes to their current setup.

There are, of course, security considerations, especially regarding fraud prevention and handling of ownership cycles. Read the aforementioned article if you want to read about strategies to prevent scams during token sales and cautions about scenarios where an ERC-721 token ends up being owned by its own token bound account, which could lock up the assets indefinitely.

In general, ERC-6551 aims to expand the capabilities of NFTs, enabling a wide range of new use cases for NFTs and their interaction with other assets and applications on the blockchain.

## About the TabbitTickets

In this repo you will find two approaches.

- **TabbitTicket.sol**
  Here, you need to create instances of the registry, the account, and the ERC-721 and follow the process of linking them all together. As you can see in the test cases, it is necessary to instantiate the ERC-721 (`TabbitTicket.sol`), the ERC6551 Account (`TabbitTicketAccount.sol`), and the registry (`ERC6551Registry.sol`). Then you just need to generate an implementation with the registry's `createAccount` function. Afterward, you can load and redeem the balance to the gift card.

```solidity
    TabbitTicket = await ethers.getContractFactory("TabbitTicket");
    tabbitTicket = await TabbitTicket.deploy();
    await tabbitTicket.deployed();
    await tabbitTicket.mint(addr1.address,"[INSERT THE IMAGE ADDRESS HERE]");
    tokenId = await tabbitTicket.nextId();

    TabbitTicketAccount = await ethers.getContractFactory("TabbitTicketAccount");
    tabbitTicketAccount = await TabbitTicketAccount.deploy();
    await tabbitTicketAccount.deployed();

    ERC6551Registry = await ethers.getContractFactory("ERC6551Registry");
    erc6551Registry = await ERC6551Registry.deploy();
    await erc6551Registry.deployed();

    chainId = await owner.getChainId();
    salt = ethers.utils.hexlify(ethers.utils.randomBytes(32));

    deployedAccountTx = await erc6551Registry.createAccount(tabbitTicketAccount.address, chainId, tabbitTicket.address, tokenId, salt, "0x");
```

## Run the code

- The code is configured to be deployed in Mumbai (Testnet). You can find a faucet [here](https://mumbaifaucet.com/)

- You need to setup a `.env` file with the `PRIVATE_KEY` variable and assign it your private key. You can use the `sample.env`, just rename it to `.env` and change the values.

### Install

```shell
npm install
```

### Compile

```shell
npx hardhat compile
```

### Test

```shell
npx hardhat test
```

### Deploy

#### Deploy Contracts for the GitfCard Approach

```shell
npx hardhat run --network mumbai scripts/deployTabbitTicket.js
```

## Todos

- Create `TabbitTicketLibrary.sol` and move some functions such as `generateRandomSalt` and `nonce`
- Create interfaces for the gift card contracts

## Disclaimer

This code is for educational purposes, requires upgrades and improvements and, of course, it is not audited. So, use it wisely!

Enjoy!
