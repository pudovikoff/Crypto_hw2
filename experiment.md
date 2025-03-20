# Sepolia Testnet Deployment Experiment

This document details the deployment and testing of the upgradeable smart contract system on the Sepolia testnet.

## Deployed Contracts

- **BoxImplementation V1**: [0xD6B947648171b0e69114bf48BC8f6ae524BEd866](https://sepolia.etherscan.io/address/0xD6B947648171b0e69114bf48BC8f6ae524BEd866)
- **TestVersionControlledProxy**: [0x051596D8e3027917f7e281be6c08584e9d099D60](https://sepolia.etherscan.io/address/0x051596D8e3027917f7e281be6c08584e9d099D60)
- **BoxImplementationV2**: [0x3B208417751D7c4610bd7617C52C56f13fEB7e39](https://sepolia.etherscan.io/address/0x3B208417751D7c4610bd7617C52C56f13fEB7e39)

## Deployment Process

### Initial Deployment

The initial deployment included:
- BoxImplementation (V1)
- TestVersionControlledProxy pointing to the V1 implementation

```bash
forge script script/Deploy.s.sol:DeployScript --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
```

### Testing V1 Functionality

After deploying, we verified the proxy was working correctly by setting a value:

```bash
# Set a value through the proxy
cast send 0x051596D8e3027917f7e281be6c08584e9d099D60 "setValue(uint256)" 42 --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

# Verify the value was set
cast call 0x051596D8e3027917f7e281be6c08584e9d099D60 "getValue()(uint256)" --rpc-url $SEPOLIA_RPC_URL
# Output: 42

# Check the version
cast call 0x051596D8e3027917f7e281be6c08584e9d099D60 "version()(string)" --rpc-url $SEPOLIA_RPC_URL
# Output: "v1"
```

### Upgrading to V2

Next, we deployed BoxImplementationV2 and upgraded the proxy:

```bash
export PROXY_ADDRESS=0x051596D8e3027917f7e281be6c08584e9d099D60
forge script script/Upgrade.s.sol:UpgradeScript --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast -vvvv
```

### Testing V2 Functionality

After upgrading, we verified:

```bash
# Check the new version
cast call 0x051596D8e3027917f7e281be6c08584e9d099D60 "version()(string)" --rpc-url $SEPOLIA_RPC_URL
# Output: "v2"

# Verify the value persisted through the upgrade
cast call 0x051596D8e3027917f7e281be6c08584e9d099D60 "getValue()(uint256)" --rpc-url $SEPOLIA_RPC_URL
# Output: 42

# Test the new V2 functionality
cast send 0x051596D8e3027917f7e281be6c08584e9d099D60 "setMessage(string)" "Hello from Sepolia" --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

# Verify the message was set
cast call 0x051596D8e3027917f7e281be6c08584e9d099D60 "getMessage()(string)" --rpc-url $SEPOLIA_RPC_URL
# Output: "Hello from Sepolia"
```

### Rolling Back to V1

Finally, we tested the rollback functionality:

```bash
# Roll back to V1
cast send 0x051596D8e3027917f7e281be6c08584e9d099D60 "rollbackTo(uint256)" 0 --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

# Verify we're back to V1
cast call 0x051596D8e3027917f7e281be6c08584e9d099D60 "version()(string)" --rpc-url $SEPOLIA_RPC_URL
# Output: "v1"

# Verify the value persisted
cast call 0x051596D8e3027917f7e281be6c08584e9d099D60 "getValue()(uint256)" --rpc-url $SEPOLIA_RPC_URL
# Output: 42

# Verify V2 functionality is no longer available
cast call 0x051596D8e3027917f7e281be6c08584e9d099D60 "getMessage()(string)" --rpc-url $SEPOLIA_RPC_URL
# Error: execution reverted
```

## Conclusions

The experiment on Sepolia successfully demonstrated:

1. **Initial Deployment**: Smooth deployment of the system
2. **Storage Persistence**: Values set in V1 persisted through upgrade to V2 and rollback to V1
3. **Successful Upgrade**: Added new functionality (getMessage/setMessage) in V2
4. **Successful Rollback**: Reverted to V1 and verified V2 functionality was no longer available
5. **Versioning**: Proper tracking of implementation versions

This confirms that our proxy pattern works correctly, allowing for upgrades and rollbacks while preserving state. 