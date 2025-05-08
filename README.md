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

| Option | Command              | Description                                                                                  |
|:------:|----------------------|----------------------------------------------------------------------------------------------|
| **1**  | `setup`              | Installs dependencies, Docker, Aztec CLI; configures `.env`; starts your validator node.    |
| **2**  | `get_apprentice`     | Fetches the latest L2 tip block and proof for your apprentice role.                          |
| **3**  | `register_validator` | Registers your validator on L1 using your public and private keys.                           |
| **4**  | `stop_node`          | Stops the local Aztec node process and removes its Docker containers.                        |
| **5**  | `restart_node`       | Stops then restarts the node, preserving your `.env` settings.                               |
| **6**  | `change_rpc`         | Prompts to update RPC & Beacon URLs in `.env`, then restarts the node.                       |
| **7**  | `wipe_data`          | Deletes local blockchain data and restarts the node (fresh sync).                            |
| **8**  | `full_clean`         | Stops node, removes all Aztec CLI data and `.env` (reset environment).                       |
| **9**  | `reinstall_node`     | Runs **Stop → Full Clean → Setup** in one step for a full reinstallation.                    |
| **x**  | Exit                 | Exit the script.                                                                             |


## ⚙️ Behind the Scenes

- **install_dependencies()**:
  1. Detects & kills any processes holding **apt** or **dpkg** locks, to avoid hangs.
  2. Updates package lists and upgrades installed packages.
  3. Installs core tools: `curl`, `git`, `build-essential`, `tmux`, etc.
  4. Sets up the official Docker repository and installs Docker Engine.

- **setup()**:
  1. Calls `install_dependencies()`.
  2. Installs the Aztec CLI if not present: `curl -sSf https://install.aztec.network | bash`.
  3. Runs `aztec-up alpha-testnet`.
  4. Prompts for and saves:
     - **Sepolia RPC URL**
     - **Sepolia Beacon URL**
     - **Validator PUBLIC key**
     - **Validator PRIVATE key**
     - **P2P IP** (auto-detected or manually entered)
  5. Persists credentials in a secured `.env` file.
  6. Launches the node with your settings.

- **Other Functions** mirror the menu options, handling node stop/restart, data wipe, and validator registration.


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

## 📝 License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

*Happy validating!* 😀
