```bash
#!/usr/bin/env bash
# manage_node.sh – All-in-one Aztec Alpha-Testnet Validator Manager

set -euo pipefail

# === Dependency Check ===
# Ensure required commands are installed: git, curl, screen, docker, jq
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"
missing=false
for cmd in git curl screen docker jq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    missing=true
    echo -e "${YELLOW}Dependency '$cmd' not found.${RESET}"
    read -rp "Install '$cmd' now? [Y/n] " ans
    ans=${ans:-Y}
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y "$cmd"
      elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y "$cmd"
      else
        echo -e "${RED}No supported package manager found. Please install '$cmd' manually.${RESET}" >&2
        exit 1
      fi
    else
      echo -e "${RED}Cannot continue without '$cmd'. Exiting.${RESET}" >&2
      exit 1
    fi
  fi
done
if [ "$missing" = false ]; then
  echo -e "${GREEN}All dependencies are present.${RESET}"
fi

# ANSI colors
BLUE="\033[0;34m"
BOLD="\033[1m"
RESET="\033[0m"

# Globals
SCREEN_NAME="aztec"
ENV_FILE=".env"
LOG_FILE="aztec_node.log"
ARCHIVE_DATA_DIR="$HOME/.aztec/alpha-testnet/data"

# Print ASCII banner by KEVIN
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

# Load .env if exists
_load_env() {
  [ -f "$ENV_FILE" ] && . "$ENV_FILE"
}

# Save config to .env
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

# Ensure jq is installed (used by get_apprentice)
_require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing jq...${RESET}"
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install -y jq
    elif command -v yum >/dev/null 2>&1; then
      sudo yum install -y jq
    else
      echo -e "${RED}Please install 'jq' manually.${RESET}" >&2
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

  # Detect public IP
  P2P_IP=$(curl -sS ipv4.icanhazip.com || echo "")
  [ -z "$P2P_IP" ] && { echo -n "→ Public IP: "; read -r P2P_IP; }

  _save_env
  echo -e "${GREEN}Configuration saved to $ENV_FILE${RESET}\n"

  echo -e "${YELLOW}Starting node now...${RESET}"
  restart_node
  echo -e "${GREEN}Node started. Logs at $LOG_FILE${RESET}\n"
}

# 2) Get Role Apprentice
get_apprentice() { ... }
# 3) Register Validator
register_validator() { ... }
# 4) Stop Node
stop_node() { ... }
# 5) Restart Node
restart_node() { ... }
# 6) Change RPC
change_rpc() { ... }
# 7) Delete Node Data
delete_node_data() { ... }
# 8) Full Clean
delete_full_node() { ... }
# 9) Reinstall Node
reinstall_node() { ... }
# 10) Git Pull
git_pull() { ... }
# 0) Show Logs
show_logs() { ... }

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
