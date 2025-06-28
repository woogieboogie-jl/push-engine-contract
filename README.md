# Chainlink **DataStreamsFeed.sol** Reference Repo

> A minimal example of deploying and operating a Chainlink **Data Streams** consumer contract.  
> This repository contains an opinionated wrapper around the community-maintained
> [`DataStreamsFeed.sol`](https://github.com/adrastia-oracle/adrastia-chainlink-data-streams/blob/main/contracts/feed/DataStreamsFeed.sol) implementation from
> Adrastia.

The goal is to give you a quick, copy-pasteable starting point for:

* deploying your own on-chain `DataStreamsFeed` instance,
* assigning the correct roles, and
* pushing fresh price data on-chain via an off-chain **transmitter**.

> **DYOR!**
> This project is a community endeavour – audit the code and contracts before
> moving real value.

---

## 1&nbsp;· Prepare the environment

| What | Why | Where to get it |
|------|-----|-----------------|
| **Verifier Proxy address** | Every chain has a dedicated contract that validates Data Streams reports. | See the *Verifier Addresses* table in the Chainlink docs → <https://docs.chain.link/data-streams/crypto-streams?page=1&testnetPage=1&testnetSearch=eth> |
| **LINK & native tokens**   | You'll pay the verification fee in LINK and gas in the native token. | Faucets: <https://faucets.chain.link><br>LINK contract list: <https://docs.chain.link/resources/link-token-contracts> |
| **RPC URL**                | Foundry & `cast` need it to send txs. | Chainlist: <https://chainlist.org/> |
| **Private key**            | Account that will own the feed and pay fees. | Export from your wallet → store in `.env` as `PRIVATE_KEY=<hex>` |

Create a `.env` file in the repo root:

```bash
PRIVATE_KEY=<0xYOUR_PRIVATE_KEY>
RPC_URL_AVAX_FUJI=<https://...>
RPC_URL_ARBITRUM_SEPOLIA=<https://...>
```

*(Add any other RPCs you plan to use.)*

---

## 2&nbsp;· Install & configure

```bash
# dependencies
pnpm add --save-dev @openzeppelin/contracts @chainlink/contracts

# install Foundry if you haven't yet
curl -L https://foundry.paradigm.xyz | bash && foundryup
```

`foundry.toml` already contains the required remappings:

```toml
remappings = [
  "@openzeppelin/contracts/=node_modules/@openzeppelin/contracts/",
  "@chainlink/contracts/=node_modules/@chainlink/contracts/",
  "forge-std/=lib/forge-std/src/"
]
```

RPC endpoints are also pre-configured (see `[rpc_endpoints]`).  Edit them if you
prefer different providers.

---

## 3&nbsp;· Customise your feed contract

`DataStreamsFeed` constructor
```solidity
constructor(
    address verifierProxy_,
    bytes32 _feedId,
    uint8   _decimals,
    string  memory _description
)
```

Fill in:

1. `verifierProxy_` – the address from step 1.
2. `_feedId` – 32-byte identifier of the stream you want to mirror (e.g. ETH/USD).  
   Example: `0x000359843a543ee2fe414dc14c7e7920ef10f4372990b79d6361cdc0dd1ba782`.
3. `_decimals` – usually **8**.
4. `_description` – human-readable label, e.g. "ETH / USD Feed".

Edit `script/DeployDataStreamsFeed.s.sol` (or the role-assign variant) with your
values, **or** pass them as CLI arguments (see below).

---

## 4&nbsp;· Deploy & verify

### Option A · One-shot deploy **with** role assignment

```bash
forge script script/DeployDataStreamsFeedWithRoleAssign.s.sol:DeployDataStreamsFeedWithRoleAssign \
  --rpc-url $RPC_URL_AVAX_FUJI \
  --private-key $PRIVATE_KEY      \
  --broadcast
```

This grants the caller `ADMIN` and `REPORT_VERIFIER` automatically.

### Option B · Deploy only

```bash
forge script script/DeployDataStreamsFeed.s.sol:DeployDataStreamsFeed \
  --rpc-url $RPC_URL_AVAX_FUJI \
  --private-key $PRIVATE_KEY \
  --broadcast
```

Then grant roles manually:

```bash
# REPORT_VERIFIER role hash (= keccak256("REPORT_VERIFIER_ROLE"))
ROLE=0xf9f8c20c4c3b902ac9f63b3ab127d0fa52ad9efa682a9cbbead7833d9777cd4e

cast send <DEPLOYED_FEED_ADDRESS> "grantRole(bytes32,address)" $ROLE <EOA_ADDRESS> \
  --rpc-url $RPC_URL_AVAX_FUJI \
  --private-key $PRIVATE_KEY
```

### (Optional) Verify the contract on RouteScan/Etherscan

```bash
forge verify-contract \
  --chain-id 43113 \
  --verifier etherscan \
  --verifier-url "https://api.routescan.io/v2/network/testnet/evm/43113/etherscan/api" \
  <DEPLOYED_FEED_ADDRESS> \
  src/feed/DataStreamsFeed.sol:DataStreamsFeed \
  --flatten \
  --etherscan-api-key <YOUR_API_KEY>
```

---

## 5&nbsp;· Run the transmitter

Clone <https://github.com/woogieboogie-jl/chainlink-datastreams-transmitter> and
follow its README.  Key points:

1. Copy `config-chainlink-example.yml` and fill in your **verifier address**,
   feed ID, contract address, and RPC.
2. The transmitter pushes reports via
   ```solidity
   updateReport(uint16 reportVersion, bytes verifiedReportData)
   ```
   which we now fully support.
3. Bring everything up:
   ```bash
   docker compose up -d
   ```

---

## Reference deployments

| Network | Address | Explorer |
|---------|---------|----------|
| Avalanche Fuji | `0xb3DCAB3217cC2f8f19A9CAa555f5f7C8BB5cB749` | <https://testnet.snowtrace.io/address/0xb3DCAB3217cC2f8f19A9CAa555f5f7C8BB5cB749> |
| Arbitrum Sepolia | `0x180473Ff989D30F0eDB4a159174C1964A504854D` | <https://testnet.routescan.io/address/0x180473Ff989D30F0eDB4a159174C1964A504854D/contract/421614/code> |
| Unichain Sepolia | `0x74CD225023c01D6B6244913F6Ce2B899482944f3` | <https://testnet.routescan.io/address/0x74CD225023c01D6B6244913F6Ce2B899482944f3/contract/1301/code> |

---

### Troubleshooting

* **Gas estimation too high** → adjust `gasCap` in `foundry.toml` or transmitter config.
* **`REPORT_VERIFIER` missing** → make sure you granted the role to your
  transmitter's address.
* **LINK balance 0** → top up via faucet and approve LINK spend if needed.

Happy building! 🚀
