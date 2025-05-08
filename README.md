# Aztec Network Validator Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

A simple, all-in-one Bash script to install, configure, and manage your **Aztec Alpha-Testnet** validator node.

---

## 📋 Prerequisites

- **OS**: Debian/Ubuntu-based system (tested on 20.04+)
- **Terminal**: `bash` (v4+) and [`screen`](https://tiswww.case.edu/php/chet/screen/) for a resilient session
- **Version Control**: `git`
- **Machine Specs**: 8‑Core CPU, 16 GiB RAM, 1 TB NVMe SSD
- **Network**: ≥25 Mbps up/down bandwidth (typical consumer desktop or laptop is sufficient)
- **Server Requirements**: Ensure these specs are met; if not, reach out for assistance.
- **RPC Endpoint**: For best performance, use a paid Ankr RPC. For a free alternative, try DRPC: https://drpc.org?ref=523696

> **Tip:** Start in `screen` so your node keeps running even if you disconnect:
> ```bash
> screen -S aztec
> ```

---

## 🚀 Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/fzkvn/aztec-network.git
   cd aztec-network
   ```
2. **Make the manager script executable**:
   ```bash
   chmod +x manage_node.sh
   ```
3. **Run the manager**:
   ```bash
   ./manage_node.sh
   ```

---

## 📖 Menu & Commands

Upon running `./manage_node.sh`, you’ll see:

```
1) Setup Node Validator
2) Get Role Apprentice
3) Register Validator
4) Stop Node
5) Restart Node
6) Change RPC
7) Delete Node Data
8) Full Clean
9) Reinstall Node
x) Exit
```

| Option | Command              | Description                                                                                 |
|:------:|----------------------|---------------------------------------------------------------------------------------------|
| **1**  | `setup`              | Installs dependencies, Docker, Aztec CLI; saves `.env`; starts your validator node.         |
| **2**  | `get_apprentice`     | Fetches the latest L2 tip block and proof.                                                 |
| **3**  | `register_validator` | Registers your validator on L1 with your keys.                                             |
| **4**  | `stop_node`          | Stops the Aztec node process and removes Docker containers.                                 |
| **5**  | `restart_node`       | Restarts your node, preserving config.                                                      |
| **6**  | `change_rpc`         | Updates RPC/Beacon URLs in `.env`, then restarts the node.                                 |
| **7**  | `wipe_data`          | Deletes local chain data only, allowing a fresh sync without full reinstall.                |
| **8**  | `full_clean`         | Stops node and removes all Aztec CLI data plus `.env` (complete reset).                    |
| **9**  | `reinstall_node`     | Runs **Stop → Full Clean → Setup**, automatically clearing port locks and reinstalling.    |
| **x**  | Exit                 | Exit the script.                                                                            |

---

## 🔒 Environment File (`.env`)

Created at repo root during setup:

```ini
RPC_URL="<YOUR_SEPOLIA_RPC_URL>"
RPC_BEACON_URL="<YOUR_BEACON_RPC_URL>"
PUBLIC_KEY="<YOUR_VALIDATOR_PUBLIC_KEY>"
PRIVATE_KEY="<YOUR_VALIDATOR_PRIVATE_KEY>"
P2P_IP="<YOUR_NODE_IP>"
```

Keep this file secure—**it contains your private key**.

---

## 🔑 Secure Input Handling

When entering your **Validator PRIVATE key**, the script uses hidden input (`read -rsp`), so it will **not** be echoed on-screen. Just paste once and press **Enter**.

---

## 🛠️ Common Issues & Solutions

- **Port 8080 In Use**:
  - If the JSON-RPC port (8080) is occupied, choose **9) Reinstall Node**, which will clear the lock and restart on a clean port.

- **Stuck Block Stream**:
  - Choose **7) Delete Node Data** to remove only the local chain data for a fresh sync without losing your config.

- **Old Proof / RPC Errors**:
  - Choose **6) Change RPC** and provide a new RPC URL (Ankr or DRPC) to refresh proofs.

- **Get Role Apprentice Missing Data**:
  - If option **2** fails, run **9) Reinstall Node** to reset and retry.

- **P2P “goodbye” Error Message**:
  - If you see a `p2p error in with aztec/req/goodbye`, your node is fine—this is a benign message.

---

## ⚙️ Behind the Scenes

- **install_dependencies()**:
  1. Detects and kills any processes locking **apt** or **dpkg**.
  2. Updates packages and installs core tools (`curl`, `git`, `tmux`, etc.).
  3. Sets up the official Docker repo and installs Docker Engine.

- **setup()**:
  1. Runs `install_dependencies()`.
  2. Installs Aztec CLI via `curl -sSf https://install.aztec.network | bash`.
  3. Executes `aztec-up alpha-testnet`.
  4. Prompts and saves your RPC, Beacon URL, public/private keys, and P2P IP to `.env`.
  5. Launches the node with these settings.

- **Other Functions** handle node stop/restart, data wipe, and validator registration as per the menu.

---

## 📝 License

Licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

*Happy validating!* 😀
