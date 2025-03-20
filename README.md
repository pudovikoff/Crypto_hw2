# Crypto_hw2

## Project Overview

Note, this repository was created with wide use of LLMs and cursor.sh software.

This repository implements a version control system for an upgradeable smart contract using a proxy pattern. The implementation consists of:

- **TestVersionControlledProxy**: A proxy contract that delegates calls to the current implementation and manages version history
- **BoxImplementation**: The V1 implementation with basic value storage functionality
- **BoxImplementationV2**: An upgraded implementation that adds message storage functionality

The proxy maintains an array called `versionHistory` to store all available implementation addresses, and a variable `currentVersion` that indicates the active implementation. The upgrade process via `upgradeTo` registers the new implementation and updates `currentVersion`, while `rollbackTo` allows reverting to any previous implementation in the version history.

## Testnet Deployment

This project has been deployed and tested on the Sepolia testnet. See [experiment.md](experiment.md) for details about the deployment process, contract addresses, and test results.

## Key Features

- **Storage Preservation**: The proxy pattern ensures that storage values persist across upgrades
- **Version Tracking**: All implementation versions are tracked and can be accessed
- **Rollback Capability**: The system can be reverted to any previous implementation
- **Delegate Calls**: Function calls to the proxy are delegated to the current implementation

