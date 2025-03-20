# Crypto_hw2

## Project Overview

This repository implements a version control system for an upgradeable smart contract using a proxy pattern. The implementation consists of:

- **TestVersionControlledProxy**: A proxy contract that delegates calls to the current implementation and manages version history
- **BoxImplementation**: The V1 implementation with basic value storage functionality
- **BoxImplementationV2**: An upgraded implementation that adds message storage functionality

The proxy maintains an array called `versionHistory` to store all available implementation addresses, and a variable `currentVersion` that indicates the active implementation. The upgrade process via `upgradeTo` registers the new implementation and updates `currentVersion`, while `rollbackTo` allows reverting to any previous implementation in the version history.

## Key Features

- **Storage Preservation**: The proxy pattern ensures that storage values persist across upgrades
- **Version Tracking**: All implementation versions are tracked and can be accessed
- **Rollback Capability**: The system can be reverted to any previous implementation
- **Delegate Calls**: Function calls to the proxy are delegated to the current implementation

## Project Structure

- `src/BoxImplementation.sol`: V1 implementation with basic functionality
- `src/BoxImplementationV2.sol`: V2 implementation with enhanced functionality
- `test/VersionControlledProxy.t.sol`: Contains both the proxy contract and tests
- `script/Deploy.s.sol`: Script to deploy the V1 implementation and proxy
- `script/Upgrade.s.sol`: Script to deploy the V2 implementation and upgrade the proxy

## Foundry

This project uses Foundry, a blazing fast toolkit for Ethereum application development written in Rust.

Foundry consists of:

- **Forge**: Ethereum testing framework
- **Cast**: Swiss army knife for interacting with EVM smart contracts
- **Anvil**: Local Ethereum node
- **Chisel**: Solidity REPL

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
# Deploy the initial implementation and proxy
$ forge script script/Deploy.s.sol:DeployScript --rpc-url <your_rpc_url> --broadcast -vvvv

# Upgrade to V2 implementation
$ export PRIVATE_KEY=<your_private_key>
$ export PROXY_ADDRESS=<deployed_proxy_address>
$ forge script script/Upgrade.s.sol:UpgradeScript --rpc-url <your_rpc_url> --broadcast -vvvv
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

### Interact with the contract

```shell
# Get the current version
$ cast call <proxy_address> "version()(string)" --rpc-url <your_rpc_url>

# Set a value
$ cast send <proxy_address> "setValue(uint256)" 42 --rpc-url <your_rpc_url> --private-key <your_private_key>

# Get the value
$ cast call <proxy_address> "getValue()(uint256)" --rpc-url <your_rpc_url>

# After upgrading to V2, set a message
$ cast send <proxy_address> "setMessage(string)" "Hello World" --rpc-url <your_rpc_url> --private-key <your_private_key>

# Get the message (V2 only)
$ cast call <proxy_address> "getMessage()(string)" --rpc-url <your_rpc_url>

# Roll back to V1
$ cast send <proxy_address> "rollbackTo(uint256)" 0 --rpc-url <your_rpc_url> --private-key <your_private_key>
```
