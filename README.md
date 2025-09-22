##  Drosera Suspicious Allowance Trap 🚨

This repository contains a Drosera trap designed to detect and respond to suspicious ERC20 token allowance increases in real-time. Built to demonstrate practical decentralized security monitoring that can help protect DeFi users from approval based exploits and unauthorized token transfers.

##  What Are Allowance-Based Attacks? 🤔

ERC20 token allowances allow users to approve third parties (like smart contracts) to spend tokens on their behalf. While essential for DeFi operations, this mechanism can be weaponized by malicious actors.

In an allowance based attack, a malicious contract tricks users into approving large token amounts, then drains their wallets. These attacks often involve:
- **Phishing contracts** that request unlimited approvals
- **Compromised DeFi protocols** that suddenly drain user allowances  
- **Social engineering** to get users to approve malicious spenders
- **MEV bots** that front-run legitimate transactions with malicious approvals

This trap provides an early warning system to detect when allowances spike unexpectedly, potentially catching attacks in progress.

##  What Does This Trap Do?

This Drosera trap provides a real-time, on-chain allowance monitoring. It is designed to:

- **Monitor Token Pairs**: Continuously watch specific owner/spender pairs for allowance changes
- **Detect Suspicious Spikes**: Identify when allowances increase beyond configurable thresholds 
- **Whitelist Protection**: Ignore allowance increases for trusted spenders (like verified DEX contracts)
- **Trigger Automated Response**: When suspicious activity is detected, immediately call a response contract to execute security actions

All of this happens decentrally, without relying on any off-chain infrastructure.


## Technologies Used 🛠️

| Layer | Tool / Protocol |
|-------|----------------|
| Security Engine | Drosera |
| Blockchain | Ethereum Hoodi Testnet |
| Smart Contracts | Solidity (^0.8.20) |
| Dev Framework | Foundry |
| Testing | Forge with comprehensive test suite |

## Response Mechanism 📝

When suspicious allowance activity is detected, the trap triggers an automated response:

**1. Detection Logic:**
```solidity
function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
    // Compare current vs previous allowances
    // Trigger if increase >= threshold AND spender not whitelisted
    if (delta >= THRESHOLD && !isWhitelisted(spender)) {
        return (true, abi.encode(owner, spender, previousAllowance, currentAllowance));
    }
}
```

**2. Automated Response:**
```solidity
function executeAllowance(
    address owner,
    address spender, 
    uint256 previousAllowance,
    uint256 currentAllowance
) external {
    emit SuspiciousAllowanceDetected(owner, spender, previousAllowance, currentAllowance);
    // Additional response logic can be added here
}
```

This creates a permanent, on-chain record of detected threats while enabling custom response actions.

## Trap Configuration

**Current Deployment Details:**
- **Trap Contract**: `0x7D06f46082e026fD11919e64d9c9157bF8BD59eF`
- **Response Contract**: `0x6b9A80D21e738FE29165Eef96FF11efe60824601`  
- **Mock Token**: `0xA2d07904D9729D8E1bE1748B2a869Afb3Baa1410`
- **Network**: Hoodi Testnet (Chain ID: 560048)

**Configuration Parameters:**
```toml
[traps.suspicious_allowance]
cooldown_period_blocks = 6
min_number_of_operators = 1  
max_number_of_operators = 2
block_sample_size = 2
private_trap = true
```

## Project Structure 📂

```
suspicious-allowance-trap/
├── src/
│   ├── SuspiciousAllowanceTrap.sol          # Main trap with constructor params
│   ├── SuspiciousAllowanceTrapDeployable.sol # Deployable version for operators
│   ├── ResponseContract.sol                  # Handles trap responses
│   ├── MockERC20.sol                        # Test token contract
│   └── ITrap.sol                           # Drosera trap interface
├── test/
│   └── SuspiciousAllowanceTrap.t.sol       # Comprehensive test suite
├── script/
│   ├── DeploySuspiciousAllowanceTrap.s.sol # Main deployment script
│   └── DeployResponseContract.s.sol        # Response contract deployment  
├── drosera.toml                            # Drosera operator configuration
├── foundry.toml                            # Foundry project configuration
└── .env.example                            # Environment variable template
```

## Setup & Deploy

### Prerequisites
- Foundry installed
- Access to Hoodi testnet RPC
- Wallet with testnet ETH for deployments

### 1. Clone and Install Dependencies
```bash
git clone https://github.com/Affanuu/suspicious-allowance-trap.git
cd suspicious-allowance-trap
forge install
forge build
```

### 2. Configure Environment  
```bash
cp .env.example .env
# Edit .env with your private key and RPC URL (never commit .env!)
```

### 3. Deploy Contracts
```bash
# Deploy the trap and response contracts
forge script script/DeploySuspiciousAllowanceTrap.s.sol \
  --rpc-url $RPC_URL_HOODI \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### 4. Set Up Drosera Operator
```bash
# Configure and apply the trap
DROSERA_PRIVATE_KEY=$PRIVATE_KEY drosera apply
```

## Testing

The project includes comprehensive tests covering all trap functionality:

```bash
# Run all tests
forge test

# Run with verbose output
forge test -vvv

# Run specific test functions
forge test --match-test test_trigger_on_spike -vvv
```

**Test Coverage:**
- ✅ No trigger on small allowance increases (< threshold)
- ✅ Trigger on suspicious spikes (>= threshold) 
- ✅ Whitelist functionality prevents false positives
- ✅ Data collection and encoding
- ✅ Gas usage optimization
- ✅ Edge cases and error conditions

## How It Works

**1. Monitoring Setup:**
```solidity
// Add owner/spender pairs to monitor
trap.addPair(tokenOwner, potentialMaliciousSpender);

// Whitelist trusted spenders to avoid false positives  
trap.addToWhitelist(uniswapRouter);
```

**2. Continuous Monitoring:**
The trap collects allowance data every block and compares with previous values to detect suspicious increases.

**3. Threshold Detection:**
When an allowance increases by more than the threshold amount AND the spender is not whitelisted, the trap triggers.

**4. Automated Response:**
The response contract is called automatically, creating an on-chain record and potentially executing additional security measures.

## Use Cases 💡

**Personal Security:**
- Monitor your own token approvals across different protocols
- Get alerts when wallets you control approve large amounts unexpectedly
- Early warning system for compromised wallets

**Protocol Security:**  
- Monitor user approvals to protocol contracts
- Detect when users approve unusually large amounts
- Identify potential phishing attacks targeting your users

**Institutional Monitoring:**
- Track treasury wallet approvals
- Monitor employee wallet security
- Compliance reporting for token approval activities

## Future Improvements

This project provides a solid foundation that could be extended with:

**Enhanced Detection Logic:**
**Advanced Response Mechanisms:**
**Broader Protocol Support:**
**Performance Optimizations:**

##  Operator Performance ⚡

**Current Metrics:**
- **Collect Gas Usage**: ~40,396 gas
- **ShouldRespond Gas Usage**: ~33,010 gas  
- **Block Processing Time**: ~694ms average
- **Bootstrap Time**: ~4.9s
- **Network Participation**: Successfully reaching consensus thresholds


Contributions are welcome! This project demonstrates practical decentralized security monitoring. Areas for contribution:

- Additional test cases and edge conditions
- Gas optimization improvements  
- Enhanced detection algorithms
- Integration with other security tools
- Documentation improvements

---

**⚠️ Disclaimer:** This trap is deployed on Hoodi testnet for demonstration purposes. Production deployment requires thorough testing and security audits. Always verify contract addresses and configurations before use.
]
