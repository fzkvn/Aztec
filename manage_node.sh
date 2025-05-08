```bash
#!/usr/bin/env bash
# manage_node.sh – All-in-one Aztec Alpha-Testnet Validator Manager

set -euo pipefail

# ANSI colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
BOLD="\033[1m"
RESET="\033[0m"

# Globals
SCREEN_NAME="aztec"
ENV_FILE=".env"
LOG_FILE="aztec_node.log"
ARCHIVE_DATA_DIR="$HOME/.aztec/alpha-testnet/data"

# All-in-one Aztec Alpha-Testnet Validator Manager by KEVIN
print_banner() {
  cat <<'EOF'
   .  . .  .  . .  .  . .  .  . .  . . .  .  . .  .  . .  .  . .  .  .
   .       .       .       .    .. :: . .       .       .       .     
     .  .    .  .    .  .    .  tX8SX@8t . .  .   . .     . .     . . 
 .       .       .       .    .:X    ..S..            .       .       
   .  .    .  .    .  .    . . 8.    . ;: . .  . .  .   . .    . .  . 
  .    .  .    .  .    .  .  . 8. .   .%;.    .       .     .         
    .       .       .        . 8.     .tt .      . .    .    .  . . . 
  .   . .    .  .    .  .  . . 8. .   .t% . .  .     .    .           
    .     .    .  .    .     . 8     ..;X .   .   .    .   .  . .  .  
  .    .   .       .     . . ..@      .:X .     .   .    .           .
     .   .   .  .   . .      . S      .:@ . .     .   .     . .  . .  
  .    .      .   . .   .  . . t .     .8 .   . .       .  .          
    .     . .   .        .  .. : .     .8.. .      . .   .    . .  .  
  .   .            . . .. .  :   .      8 .   .  .     .    .       . 
    .   . .  . .     ..  tSS.. : .      8 ... .    .  .   .    . .    
  .         .    . . .t;%t;;S .; .      @ .::... .      .    .     .  
     . .  .    .   .  ..:.....t: .      8S8:;t8t ;. .      .    .   . 
  .          .    . :8 .... ..t; ..     8  ::: .:.. .. .  .   .   .   
    .  . . .    . . ;S .    . XS .      St . .  ..@ :       .   .    .
  .           . . :;.@ .    . @@ ..   . ;8.     :;8.X. . .    .    .  
    . .  .  . .. S8X   .    . @8 ..   . ;@ .   @8. S      .      .    
  .       . . ;:% . :@ .    . 88 .    . :X   . : .8::@.;;: . .     .  
     . .   .8 S  .. 8: .      @@ ..   . .X    .8. ;. X; ;t .   .     .
  .      ..;...   ..%% .     .t8 .    . %X ..  8  @  8;.@.   .   . .  
    .  .. S...  ..8  ; .       X .    . 8X . .. % X ..:.8 ..   .      
  .     . t.... X@ %8@ .     ...      . XS .  .:.8. ...t;.        .  .
    . . . .8    ... .t..      .       . S  .   . :S....:  . . . .     
  .      ..% .  ..S@S S@..........  ..:.%....  ...tX ::.8t.       . . 
     .  .  tS . . ; .;t:S8@8.:: 8   8:8S. S.S8888t.X :S. . : .. . .  .
  .       . ; .   :8      . @t%X ...   .X.  .@X :.. X;X;.. ..  . . . .
    . .  ...8 .  ..8;; .. .. .8 ...@8... XX:.... tX@;8 .S: . . .  . . 
  .     . . 8;....X 8:8 .  .  8 ...t 8 . :@..  .SX: ...;8.. . . . . . 
     .     . 8.. S8S   8   . 8@:.. 8 8 .   .... X@   ..   . .  . . . .
  .    .     ;:%;:. ..8t...  :88.. 8.X ..88 .. 8t:  ..;t . . . . . . .
   .  .  . .  . %X.... S :....t  . S;:..;8   ..@@ . :@:.. . . . . . . 
               . ;  .. .S.  ..:8.:. %. .@@ .. t8: ..  . . . . . . .  .
 .  .  .  .  .  ...888..    . 8..: 88..   ... :::.8%... .  . . . . . .
   .    .          .  8X.  .:. :::.XX ..;. .. .:@@:. . . . . .  . . . 
     .    . . .       : tS.:t%: %;..  :.:@XSX%:t: . . . . . . . . . .
 .    .         . .     ..tt:  . .X88X;. .. :;.... . . . . . . . . . .
   .    .  .  .     .  .    .     . ..  .        . .  . . . . . . . . 
EOF
}

# Load and save env
_load_env() {
  [ -f "$ENV_FILE" ] && . "$ENV_FILE"
}
_save_env() {
  cat > "$ENV_FILE" <<EOF
RPC_URL="$RPC_URL"
RPC_BEACON_URL="$RPC_BEACON_URL"
PUBLIC_KEY="$PUBLIC_KEY"
PRIVATE_KEY="$PRIVATE_KEY"
P2P_IP="$P2P_IP"
EOF
  chmod 600 "$ENV_FILE"
}

# Ensure jq is installed
_require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing jq...${RESET}"
    if command -v apt-get >/dev/null; then
      sudo apt-get update && sudo apt-get install -y jq
    else
      echo -e "${RED}Please install jq manually.${RESET}" >&2
      exit 1
    fi
  fi
}

# 1) Setup Node Validator
setup() {
  echo -e "${GREEN}${BOLD}=== (1) Setup Node Validator ===${RESET}"
  
  # Install Aztec CLI if missing
  if ! command -v aztec >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing Aztec CLI...${RESET}"
    curl -sSf https://install.aztec.network | bash
    export PATH="$HOME/.aztec/bin:$PATH"
  fi
  echo -e "${YELLOW}Switching to alpha-testnet...${RESET}"
  aztec-up alpha-testnet

  # Prompt for config
  echo -n "→ Sepolia execution RPC URL: " && read -r RPC_URL
  echo -n "→ Sepolia beacon RPC URL:     " && read -r RPC_BEACON_URL
  echo -n "→ Validator PUBLIC key:       " && read -r PUBLIC_KEY
  echo -n "→ Validator PRIVATE key:      " && stty -echo; read -r PRIVATE_KEY; stty echo; echo

  # Auto-detect IP
  P2P_IP=$(curl -sS ipv4.icanhazip.com || echo "")
  [ -z "$P2P_IP" ] && { echo -n "→ Public IP: "; read -r P2P_IP; }

  _save_env
  echo -e "${GREEN}Configuration saved to $ENV_FILE${RESET}\n"

  echo -e "${YELLOW}Starting node now...${RESET}"
  restart_node
  echo -e "${GREEN}Node started. Logs at $LOG_FILE${RESET}\n"
}

# 2) Get Role Apprentice
get_apprentice() {
  echo -e "${GREEN}${BOLD}=== (2) Get Role Apprentice ===${RESET}"
  _require_jq

  echo -e "Step 1: Fetch proven block number..."
  block=$(curl -s -X POST -H 'Content-Type: application/json' \
    -d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":1}' \
    http://localhost:8080 | jq -r ".result.proven.number")
  echo -e "→ Proven block: ${YELLOW}$block${RESET}"

  echo -e "Step 2: Generate sync proof..."
  proof=$(curl -s -X POST -H 'Content-Type: application/json' \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"node_getArchiveSiblingPath\",\"params\":[\"$block\",\"$block\"],\"id\":1}" \
    http://localhost:8080 | jq -r ".result")
  echo -e "→ Proof: ${YELLOW}$proof${RESET}\n"

  _load_env
  echo -e "Address:      ${YELLOW}$PUBLIC_KEY${RESET}"
  echo -e "Block-Number: ${YELLOW}$block${RESET}"
  echo -e "Proof:        ${YELLOW}$proof${RESET}\n"
  echo -e "— Use in Discord: /operator start"
}

# 3) Register Validator
register_validator() {
  echo -e "${GREEN}${BOLD}=== (3) Register Validator ===${RESET}"
  _load_env
  [ -z "${RPC_URL:-}" ] && { echo -e "${RED}Config missing; run setup first.${RESET}"; return; }
  echo -e "→ Registering ${YELLOW}$PUBLIC_KEY${RESET} on L1..."
  aztec add-l1-validator \
    --l1-rpc-urls "$RPC_URL" \
    --private-key "$PRIVATE_KEY" \
    --attester "$PUBLIC_KEY" \
    --proposer-eoa "$PUBLIC_KEY" \
    --staking-asset-handler 0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2 \
    --l1-chain-id 11155111
  echo -e "${GREEN}Registration TX sent.${RESET}\n"
}

# 4) Stop Node
stop_node() {
  echo -e "${GREEN}${BOLD}=== (4) Stop Node ===${RESET}"
  echo -e "→ Killing screen '${YELLOW}$SCREEN_NAME${RESET}'..."
  screen -S "$SCREEN_NAME" -X quit || true
  echo -e "→ Stopping Docker proxies..."
  docker ps -q --filter "ancestor=aztecprotocol/aztec" | xargs -r docker stop | xargs -r docker rm
  echo -e "${GREEN}Node stopped.${RESET}\n"
}

# 5) Restart Node
restart_node() {
  echo -e "${GREEN}${BOLD}=== (5) Restart Node ===${RESET}"
  stop_node
  _load_env
  echo -e "→ Launching in screen '${YELLOW}$SCREEN_NAME${RESET}'..."
  screen -dmS "$SCREEN_NAME" bash -c "\
aztec start --node --archiver --sequencer \
  --network alpha-testnet \
  --port 8080 \
  --l1-rpc-urls '$RPC_URL' \
  --l1-consensus-host-urls '$RPC_BEACON_URL' \
  --sequencer.validatorPrivateKey '$PRIVATE_KEY' \
  --sequencer.coinbase '$PUBLIC_KEY' \
  --p2p.p2pIp '$P2P_IP' \
  --p2p.maxTxPoolSize 1000000000 > $LOG_FILE 2>&1"
  echo -e "${GREEN}Node restarted.${RESET}\n"
}

# 6) Change RPC
change_rpc() {
  echo -e "${GREEN}${BOLD}=== (6) Change RPC ===${RESET}"
  _load_env
  echo -n "→ New execution RPC URL: " && read -r RPC_URL
  echo -n "→ New beacon RPC URL:    " && read -r RPC_BEACON_URL
  _save_env
  echo -e "${GREEN}RPC updated.${RESET}\n"
  restart_node
}

# 7) Delete Node Data
delete_node_data() {
  echo -e "${GREEN}${BOLD}=== (7) Delete Node Data ===${RESET}"
  stop_node
  echo -e "→ Removing local chain data..."
  rm -rf "$ARCHIVE_DATA_DIR"
  echo -e "${GREEN}Data wiped.${RESET}\n"
  restart_node
}

# 8) Full Clean
delete_full_node() {
  echo -e "${GREEN}${BOLD}=== (8) Delete Full Node ===${RESET}"
  stop_node
  echo -e "→ Removing Aztec CLI & data..."
  rm -rf "$HOME/.aztec"
  echo -e "→ Removing guides, logs, config..."
  rm -rf "aztec-network" "$ENV_FILE" "$LOG_FILE"
  echo -e "${GREEN}Full cleanup done.${RESET}\n"
}

# 9) Reinstall Node
reinstall_node() {
  echo -e "${GREEN}${BOLD}=== (9) Reinstall Validator Node ===${RESET}"
  stop_node
  echo -e "→ Killing leftover docker-proxy..."
  pkill -f docker-proxy || true
  echo -e "→ Removing data & config..."
  rm -rf "$ARCHIVE_DATA_DIR" "$ENV_FILE" "$LOG_FILE"
  setup
}

# 10) Git Pull
git_pull() {
  echo -e "${GREEN}${BOLD}=== (10) Git Pull ===${RESET}"
  if [ -d "aztec-network" ]; then
    echo -e "→ Pulling latest changes in aztec-network..."
    git -C aztec-network pull --ff-only
    echo -e "${GREEN}Repository updated.${RESET}\n"
  else
    echo -e "${RED}Directory 'aztec-network' not found.${RESET}\n"
  fi
}

# 0) Show Logs\show_logs() {
  echo -e "${GREEN}${BOLD}=== (0) Show Logs / Attach Screen ===${RESET}"
  if screen -list | grep -q "$SCREEN_NAME"; then
    echo -e "Attaching to screen '${YELLOW}$SCREEN_NAME${RESET}' (Ctrl-A D to detach)..."
    screen -r "$SCREEN_NAME"
  else
    echo -e "No screen session. Tailing ${YELLOW}$LOG_FILE${RESET}..."
    tail -f "$LOG_FILE"
  fi
}

# Main menu
print_banner
cat <<EOF
${BOLD}Menu:${RESET}
${YELLOW}1)${RESET} Setup Node Validator
${YELLOW}2)${RESET} Get Role Apprentice
${YELLOW}3)${RESET} Register Validator
${YELLOW}4)${RESET} Stop Node
${YELLOW}5)${RESET} Restart Node
${YELLOW}6)${RESET} Change RPC
${YELLOW}7)${RESET} Delete Node Data
${YELLOW}8)${RESET} Full Clean
${YELLOW}9)${RESET} Reinstall Node
${YELLOW}10)${RESET} Git Pull
${YELLOW}0)${RESET} Show Logs / Attach
${YELLOW}x)${RESET} Exit
EOF

read -rp "Select [0-10, x]: " choice
case "$choice" in
  1) setup ;; 2) get_apprentice ;; 3) register_validator ;; 4) stop_node ;;
  5) restart_node ;; 6) change_rpc ;; 7) delete_node_data ;; 8) delete_full_node ;;
  9) reinstall_node ;; 10) git_pull ;; 0) show_logs ;; x|X) exit 0 ;;
  *) echo -e "${RED}Invalid selection.${RESET}"; exit 1 ;;
esac
```
