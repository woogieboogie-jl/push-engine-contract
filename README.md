# Chainlink **DataStreamsFeed.sol** Reference Repo

> A minimal example of deploying and operating a Chainlink **Data Streams** consumer contract.  
> This repository contains an opinionated wrapper around the community-maintained
> [`DataStreamsFeed.sol`](https://github.com/adrastia-oracle/adrastia-chainlink-data-streams/blob/main/contracts/feed/DataStreamsFeed.sol) implementation from
> Adrastia.

The goal is to give you a quick, copy-pasteable starting point for:

* deploying your own on-chain `DataStreamsFeed` instance,
* funding the feed contract with LINK, and
* pushing fresh price data on-chain via an off-chain **transmitter**.

> **DYOR!**
> This project is a community endeavour – audit the code and contracts before
> moving real value.

---

## 1&nbsp;· Prepare the environment

| What | Why | Where to get it |
|------|-----|-----------------|
| **Verifier Proxy address** | Every chain has a dedicated contract that validates Data Streams reports. | See the *Verifier&nbsp;Addresses* table in the **[Chainlink Docs]** |
| **LINK & native tokens**   | You'll pay the verification fee in LINK and gas in the native token. | [Faucets](https://faucets.chain.link) · [LINK contracts](https://docs.chain.link/resources/link-token-contracts) |
| **RPC URL**                | Foundry & `cast` need it to send txs. | [Chainlist](https://chainlist.org) |
| **Private key**            | Account that will own the feed and pay fees. | Export from your wallet → store in `.env` as `PRIVATE_KEY=<hex>` |

Docker-compose spins up a Redis instance, so make sure **Docker Desktop** (or Docker Engine) *and* the Redis CLI are installed on your machine.

Create a `.env` file in the repo root, then load it into the current shell:

```bash
cat >.env <<EOF
PRIVATE_KEY=<0xYOUR_PRIVATE_KEY>
RPC_URL_AVAX_FUJI=<https://...>
RPC_URL_ARBITRUM_SEPOLIA=<https://...>
EOF

source .env
```

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
3. `_decimals` – usually **18**.
4. `_description` – human-readable label, e.g. "ETH / USD Feed".

Edit `script/DeployDataStreamsFeed.s.sol` with your values, **or** pass them as CLI arguments (see below).

---

## 4&nbsp;· Deploy & fund

### Deploy the contract

```bash
forge script script/DeployDataStreamsFeed.s.sol:DeployDataStreamsFeed \
  --rpc-url $RPC_URL_AVAX_FUJI \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### Fund the contract with LINK

After deployment transfer some testnet LINK to the **feed contract address** so it can pay verification fees:

```bash
# Example using cast to transfer 5 LINK (18 decimals)
cast send $LINK_TOKEN "transfer(address,uint256)" \
     <DEPLOYED_FEED_ADDRESS> 5000000000000000000 \
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

Follow these steps to bring an off-chain 📡 transmitter online.

```bash
# 1 · clone & enter
git clone -b fix/docker-dev-setup https://github.com/woogieboogie-jl/chainlink-datastreams-transmitter.git transmitter-test
cd transmitter-test

# 2 · env vars
cp .env.example .env            # create your own copy
# open .env and fill in PRIVATE_KEY, RPC urls, etc.

# 3 · required – create the runtime config
cp config-chainlink-verify-example.yml config.yml      # customise as needed

# 4 · deps & run
pnpm install                      # or pnpm install
docker compose up -d            # starts redis + node + ui

# 5 · UI
open http://localhost:3000       # dashboard
```

The transmitter continuously listens for deviation on the ETH/USD feed and, on
trigger, calls:

```solidity
verifyAndUpdateReport(bytes rawReport, bytes parameterPayload)
```

on every target contract defined in **config.yml**.

### Minimal working `config.yml`

```yaml
# --- Feeds (off-chain subscriptions) ----------------------------
feeds:
  - name: "ETH/USD"
    feedId: "0x000359843a543ee2fe414dc14c7e7920ef10f4372990b79d6361cdc0dd1ba782"

# --- Defaults ---------------------------------------------------
chainId: 1301          # default target chain – Unichain Sepolia in this file
gasCap: "150000"
interval: "*/30 * * * * *"  # every 30 s
priceDeltaPercentage: 0.01   # 0.01 %

# --- RPC & Currency metadata -----------------------------------
chains:
  # Avalanche Fuji
  - id: 43113
    name: "Avalanche Fuji Network"
    currencyName: "Fuji AVAX"
    currencySymbol: "AVAX"
    currencyDecimals: 18
    rpc: "https://api.avax-test.network/ext/bc/C/rpc"
    testnet: true

  # Arbitrum Sepolia
  - id: 421614
    name: "Arbitrum Sepolia"
    currencyName: "Arbitrum Sepolia Ether"
    currencySymbol: "ETH"
    currencyDecimals: 18
    rpc: "https://sepolia-rollup.arbitrum.io/rpc"
    testnet: true

  # Unichain Sepolia
  - id: 1301
    name: "Unichain Sepolia"
    currencyName: "Unichain"
    currencySymbol: "UNI"
    currencyDecimals: 18
    rpc: "https://unichain-sepolia.drpc.org"
    testnet: true

# --- Data-Streams Verifier addresses ----------------------------
verifierAddresses:
  - chainId: 43113  # Fuji
    address: "0x2bf612C65f5a4d388E687948bb2CF842FFb8aBB3"
  - chainId: 421614 # Arbitrum Sepolia
    address: "0x2ff010DEbC1297f19579B4246cad07bd24F2488A"
  - chainId: 1301   # Unichain Sepolia
    address: "0x60fAa7faC949aF392DFc858F5d97E3EEfa07E9EB"

# --- Target contracts (on-chain writes) -------------------------
targetChains:
  - chainId: 43113     # Fuji
    targetContracts:
      - feedId: "0x000359843a543ee2fe414dc14c7e7920ef10f4372990b79d6361cdc0dd1ba782"
        address: "0xb3DCAB3217cC2f8f19A9CAa555f5f7C8BB5cB749"
        functionName: verifyAndUpdateReport
        functionArgs: [rawReport, parameterPayload]
        skipVerify: false
        abi:
          - inputs: [{internalType: bytes,name: unverifiedReportData,type: bytes},{internalType: bytes,name: parameterPayload,type: bytes}]
            name: verifyAndUpdateReport
            outputs: []
            stateMutability: nonpayable
            type: function

  - chainId: 421614    # Arbitrum Sepolia
    targetContracts:
      - feedId: "0x000359843a543ee2fe414dc14c7e7920ef10f4372990b79d6361cdc0dd1ba782"
        address: "0x180473Ff989D30F0eDB4a159174C1964A504854D"
        functionName: verifyAndUpdateReport
        functionArgs: [rawReport, parameterPayload]
        skipVerify: false
        abi: *id001

  - chainId: 1301       # Unichain Sepolia
    targetContracts:
      - feedId: "0x000359843a543ee2fe414dc14c7e7920ef10f4372990b79d6361cdc0dd1ba782"
        address: "0x74CD225023c01D6B6244913F6Ce2B899482944f3"
        functionName: verifyAndUpdateReport
        functionArgs: [rawReport, parameterPayload]
        skipVerify: false
        abi: *id001
```

> The YAML uses an anchor `*id001` so the ABI block isn't repeated three times.

#### Need help?

* Full transmitter docs → **[README](https://github.com/woogieboogie-jl/chainlink-datastreams-transmitter#readme)**
* Example configs → `config-chainlink-example.yml` in that repo.

Once the service is running you can watch log output in `logs/` or the browser
dashboard.

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
* **LINK balance 0** → top up the feed contract via faucet.


Happy building! 🚀

[Chainlink Docs]: https://docs.chain.link/data-streams/crypto-streams?page=1&testnetPage=1&testnetSearch=eth

---

> **Security notice** – This repository contains a lightly-patched version of
> Adrastia's `DataStreamsFeed.sol`. The code **has not been audited by
> Chainlink Labs**. A comprehensive, independent security review is strongly
> recommended before any production use.
