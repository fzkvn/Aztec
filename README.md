# Aztec Alpha-Testnet Validator Manager

A single, menu-driven `manage_node.sh` script to **install**, **configure**, **manage**, and **inspect** your Aztec Alpha-Testnet validator—all in one place.

## 📦 Clone the Repo

```bash
# Clone your fork (replace with your GitHub URL if needed)
git clone https://github.com/fzkvn/aztec-network.git
cd aztec-network
```

## 🔧 Make Executable

```bash
chmod +x manage_node.sh
```

## 🚀 Run the Script

```bash
./manage_node.sh
```

You'll see a colorful menu and your **custom ASCII banner** by KEVIN.

---

## 📖 Menu Options Breakdown

| Option | Command                  | Description                                                                                                                                                                           |
| ------ | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1      | **Setup Node Validator** | Installs Aztec CLI, switches to alpha-testnet, prompts for your RPC URLs, keys, auto-detects your public IP, saves to `.env`, and **starts the node** in a `screen -S aztec` session. |
| 2      | **Get Role Apprentice**  | Fetches the latest proven block number and generates your sync-proof via RPC calls. Displays **Address**, **Block-Number**, and **Proof** for `/operator start` in Discord.           |
| 3      | **Register Validator**   | Uses your saved `.env` values to submit an `aztec add-l1-validator` transaction on Sepolia.                                                                                           |
| 4      | **Stop Node**            | Stops the `screen` session and any Docker proxies for Aztec.                                                                                                                          |
| 5      | **Restart Node**         | Re-reads `.env` and restarts the node in `screen -S aztec`, ensuring logs persist in `aztec_node.log`.                                                                                |
| 6      | **Change RPC**           | Prompts for new RPC URLs, updates `.env`, and restarts the node.                                                                                                                      |
| 7      | **Delete Node Data**     | Wipes only the local chain data directory (`~/.aztec/alpha-testnet/data`) and restarts the node.                                                                                      |
| 8      | **Full Clean**           | Completely removes the Aztec CLI installation, guide folder, logs, and config (`.env` & logs).                                                                                        |
| 9      | **Reinstall Node**       | Stops everything, kills any leftover Docker proxies, deletes all data & config, then runs **Setup** from scratch.                                                                     |
| 10     | **Git Pull**             | Updates the `aztec-network` guide repository via `git pull --ff-only`.                                                                                                                |
| 0      | **Show Logs / Attach**   | If `screen -S aztec` is running, re-attaches it; otherwise, tails `aztec_node.log`.                                                                                                   |
| x      | **Exit**                 | Quit the script.                                                                                                                                                                      |

---

## 📄 Configuration File

All configuration lives in a **single** `.env` file:

```ini
RPC_URL=YOUR_SEPOLIA_EXECUTION_RPC_URL
RPC_BEACON_URL=YOUR_SEPOLIA_BEACON_RPC_URL
PUBLIC_KEY=0xYourValidatorAddress
PRIVATE_KEY=0xYourValidatorPrivateKey
P2P_IP=your.public.ip.address
```

* Saved with permissions `600` (owner read/write only) for security.
* **Never** commit `.env` to version control.

---

## 📜 Inspecting Your Node

* **Attach to Screen**:

  ```bash
  screen -r aztec
  ```

  (Press `Ctrl-A` then `D` to detach.)

* **Tail Logs**:

  ```bash
  tail -f aztec_node.log
  ```

---

## 🛠️ Requirements

* **Bash** (Linux/macOS)
* `curl`, `git`, `screen`, `docker` installed
* `jq` (JSON parser) for **Get Role Apprentice**

---

## ⚠️ Security Notes

* Keep your `PRIVATE_KEY` safe—only stored locally in `.env`.
* Scripts run with `set -euo pipefail` to fail fast on errors.

---

**Happy validating on Aztec Alpha-Testnet!** 🚀
