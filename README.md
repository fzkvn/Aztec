# Aztec Network Validator Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

A simple, all-in-one Bash script to install, configure, and manage your **Aztec Alpha-Testnet** validator node.

---

## 📋 Prerequisites

- A Debian/Ubuntu-based system (tested on 20.04+)
- **screen** (for a resilient terminal session)
- **bash** shell (v4+)
- **git**

> **Tip:** Use `screen` so your node keeps running even if you disconnect.

- **Server Requirements:** Ensure your server meets the minimum requirements for CPU, memory, and storage. If you're all set, proceed; otherwise, reach out and I'll assist you further.
- **Recommended RPC Endpoints:** For best performance, use a paid Ankr RPC endpoint. If you prefer a free option, try DRPC: https://drpc.org?ref=523696

## 🚀 Quick Start

1. **Launch a screen session** (recommended):
   ```bash
   screen -S aztec
   ```
2. **Clone this repository**:
   ```bash
   git clone https://github.com/fzkvn/aztec-network.git
   cd aztec-network
   ```
3. **Make the script executable**:
   ```bash
   chmod +x manage_node.sh
   ```
4. **Run the manager**:
   ```bash
   ./manage_node.sh
   ```

---

## 📖 Menu & Commands

When you run `manage_node.sh`, you’ll see a menu:

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

Below is what each option does:

| Option | Command              | Description                                                                                               |
|:------:|----------------------|-----------------------------------------------------------------------------------------------------------|
| **1**  | `setup`              | Installs dependencies, Docker, Aztec CLI; configures `.env`; starts your validator node.                 |
| **2**  | `get_apprentice`     | Fetches the latest L2 tip block and proof for your apprentice role.                                       |
| **3**  | `register_validator` | Registers your validator on L1 using your public and private keys.                                        |
| **4**  | `stop_node`          | Stops the local Aztec node process and removes its Docker containers.                                     |
| **5**  | `restart_node`       | Stops then restarts the node, preserving your `.env` settings.                                            |
| **6**  | `change_rpc`         | Prompts to update RPC & Beacon URLs in `.env`, then restarts the node.                                    |
| **7**  | `wipe_data`          | Deletes local blockchain data and restarts the node (fresh sync).                                          |
| **8**  | `full_clean`         | Stops node, removes all Aztec CLI data and `.env` (reset environment).                                    |
| **9**  | `reinstall_node`     | Runs **Stop → Full Clean → Setup** in one step for a full reinstallation.                                 |
| **x**  | Exit                 | Exit the script.                                                                                          |

---

## 🔒 Environment File (`.env`)

After setup, a file named `.env` is created in the repo root:

```ini
RPC_URL="<YOUR_SEPOLIA_RPC_URL>"
RPC_BEACON_URL="<YOUR_BEACON_RPC_URL>"
PUBLIC_KEY="<YOUR_VALIDATOR_PUBLIC_KEY>"
PRIVATE_KEY="<YOUR_VALIDATOR_PRIVATE_KEY>"
P2P_IP="<YOUR_NODE_IP>"
```

Keep this file secret! It contains your private key.

---

## 🔑 Secure Input Handling

When prompted for your **Validator PRIVATE key**, the script uses hidden input (`read -rsp`), so your key will **not** be echoed on-screen. Just paste it once and press **Enter**, and it will be stored securely in `.env`.

---

## 🛠️ Common Issues & Solutions

- **Block Stream Stuck (“world block stream issue”)**:
  - **Solution:** Choose option **7) Delete Node Data** (`wipe_data`). This removes only the local blockchain data while preserving your config, allowing a fresh sync without a full reinstall.

- **Proof Too Old / RPC Errors**:
  - **Solution 1:** Use option **6) Change RPC** to switch to a healthier RPC endpoint.
  - **Solution 2:** Use **9) Reinstall Node** to fully stop, clean, and set up again, then provide a new, reliable RPC URL during setup.

- **Get Role Apprentice Not Returning Block / Proof**:
  - **Solution:** If option **2) Get Role Apprentice** fails to fetch the latest block or proof, run **9) Reinstall Node** to reset and then rerun option **2**.

---

*Happy validating!* 😀
