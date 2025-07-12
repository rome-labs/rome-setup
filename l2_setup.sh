#!/bin/bash

# --------- ENVIRONMENT VARIABLES ---------
export CHAIN_ID=1001
export SOLANA_START_SLOT=390300819
export RHEA_GAS_RECIPIENT=0xf0e0CA2704D047A7Af27AafAc6D70e995520C2B2
export PROXY_GAS_RECIPIENT=0xf0e0CA2704D047A7Af27AafAc6D70e995520C2B2
export SOLANA_RPC=https://node3.devnet-us-sol-api.devnet.romeprotocol.xyz
export JWT_SECRET=a535c9f4f9df8e00cd6a15a7baa74bb92ca47ebdf59b6f3f2d8a8324b6c1767c
export PROGRAM_ID=RPDwFyw4ekzzgyJfSrVmJgmfi51ovyqzLckYGchLpKX

export ROME_EVM_TAG=v1.0.1
export ROME_APPS_TAG=v1.0.1
export DEPOSIT_UI_TAG=v1.0.1
export GETH_TAG=v1.0.1

# --------- PATH SETUP ---------
DOCKER_DIR="docker"
KEYPAIR_DIR="$DOCKER_DIR/keys"
RHEA_CONFIG_FILE="$DOCKER_DIR/cfg/rhea-config.yml"
PROXY_CONFIG_FILE="$DOCKER_DIR/cfg/proxy-config.yml"
HERCULES_CONFIG_FILE="$DOCKER_DIR/cfg/hercules-config.yml"
COMPOSE_FILE="$DOCKER_DIR/docker-compose.yml"

RHEA_KEY_FILE="$KEYPAIR_DIR/rhea-sender.json"
PROXY_KEY_FILE="$KEYPAIR_DIR/proxy-sender.json"

# --------- OS-COMPATIBLE SED WRAPPER ---------
if [[ "$OSTYPE" == "darwin"* ]]; then
  SED_INPLACE() { sed -i '' "$@"; }
else
  SED_INPLACE() { sed -i "$@"; }
fi

# --------- KEYPAIR VALIDATION ---------
validate_keypair() {
    local file=$1
    if [[ ! -f "$file" ]]; then
        echo "Error: File $file not found."
        exit 1
    fi

    local count
    count=$(grep -o '[0-9]\+' "$file" | wc -l)
    if [[ "$count" -ne 64 ]]; then
        echo "Error: $file does not contain 64 numbers."
        exit 1
    fi
}

validate_keypair "$RHEA_KEY_FILE"
validate_keypair "$PROXY_KEY_FILE"

if [[ -z "$SOLANA_START_SLOT" || "$SOLANA_START_SLOT" == "0" ]]; then
    echo "Error: Environment variable SOLANA_START_SLOT must be set and non-zero."
    exit 1
fi

[[ -z "$CHAIN_ID" ]] && echo "CHAIN_ID is empty" && exit 1

echo "All checks passed."

# --------- CONFIG FILE UPDATES ---------

# depositui/chains.yml
CHAINS_FILE="$DOCKER_DIR/depositui/chains.yml"
SED_INPLACE "s|^\\([[:space:]]*chainId:[[:space:]]*\\).*|\\1\\\"$CHAIN_ID\\\"|" "$CHAINS_FILE"

# env.depositui
ENV_DEPOSITUI_FILE="$DOCKER_DIR/depositui/env.depositui"
SED_INPLACE "s|^\\([[:space:]]*NEXT_PUBLIC_ROLLUP_PROGRAM[[:space:]]*=\\)[[:space:]]*\\\".*\\\"|\\1 \\\"$PROGRAM_ID\\\"|" "$ENV_DEPOSITUI_FILE"

# rhea-config.yml
SED_INPLACE "s|^\([[:space:]]*chain_id:\).*|\1 $CHAIN_ID|" "$RHEA_CONFIG_FILE"
SED_INPLACE "s|^\([[:space:]]*rpc_urls:\).*|\1 [\"$SOLANA_RPC\"]|" "$RHEA_CONFIG_FILE"
SED_INPLACE "s|^\([[:space:]]*geth_engine_secret:\).*|\1 \"$JWT_SECRET\"|" "$RHEA_CONFIG_FILE"
SED_INPLACE "s|^\([[:space:]]*program_id:\).*|\1 \"$PROGRAM_ID\"|" "$RHEA_CONFIG_FILE"

# proxy-config.yml
SED_INPLACE "s|^\([[:space:]]*chain_id:\).*|\1 $CHAIN_ID|" "$PROXY_CONFIG_FILE"
SED_INPLACE "s|^\([[:space:]]*rpc_url:\).*|\1 \"$SOLANA_RPC\"|" "$PROXY_CONFIG_FILE"
SED_INPLACE "s|^\([[:space:]]*program_id:\).*|\1 \"$PROGRAM_ID\"|" "$PROXY_CONFIG_FILE"

# hercules-config.yml
SED_INPLACE "s|^\([[:space:]]*chain_id:\).*|\1 $CHAIN_ID|" "$HERCULES_CONFIG_FILE"
SED_INPLACE "s|^\([[:space:]]*rpc_url:\).*|\1 \"$SOLANA_RPC\"|" "$HERCULES_CONFIG_FILE"
SED_INPLACE "s|^\([[:space:]]*geth_engine_secret:\).*|\1 \"$JWT_SECRET\"|" "$HERCULES_CONFIG_FILE"
SED_INPLACE "s|^\([[:space:]]*program_id:\).*|\1 \"$PROGRAM_ID\"|" "$HERCULES_CONFIG_FILE"

# hercules-config: replace block_loader.client.providers[0]
awk -v rpc="$SOLANA_RPC" '
/^[[:space:]]*block_loader:/ { in_loader=1 }
/^[[:space:]]*client:/ && in_loader { in_client=1 }
/^[[:space:]]*providers:/ && in_client { in_providers=1; print; next }
in_providers && /^[[:space:]]*-[[:space:]]*".*"/ {
  print "      - \"" rpc "\""
  in_providers=0; next
}
{ print }
' "$HERCULES_CONFIG_FILE" > tmp && mv tmp "$HERCULES_CONFIG_FILE"

# start_slot updates
SED_INPLACE "s|^\([[:space:]]*start_slot:\).*|\1 $SOLANA_START_SLOT|" "$PROXY_CONFIG_FILE"
SED_INPLACE "s|^\([[:space:]]*start_slot:\).*|\1 $SOLANA_START_SLOT|" "$RHEA_CONFIG_FILE"
SED_INPLACE "s|^\([[:space:]]*start_slot:\).*|\1 $SOLANA_START_SLOT|" "$HERCULES_CONFIG_FILE"

# fee_recipients under rhea
awk -v addr="$RHEA_GAS_RECIPIENT" '
/^[[:space:]]*fee_recipients:/ {
  print; getline;
  if ($0 ~ /^[[:space:]]*-[[:space:]]*0x[0-9a-fA-F]{40}$/) {
    print "      - " addr
    next
  } else {
    print $0
  }
}
{ print }' "$RHEA_CONFIG_FILE" > tmp && mv tmp "$RHEA_CONFIG_FILE"

# fee_recipients under proxy
awk -v addr="$PROXY_GAS_RECIPIENT" '
/^[[:space:]]*fee_recipients:/ {
  print; getline;
  if ($0 ~ /^[[:space:]]*-[[:space:]]*0x[0-9a-fA-F]{40}$/) {
    print "      - " addr
    next
  } else {
    print $0
  }
}
{ print }' "$PROXY_CONFIG_FILE" > tmp && mv tmp "$PROXY_CONFIG_FILE"



# docker-compose.yml
SED_INPLACE "s|^\([[:space:]]*CHAIN_ID:\).*|\1 '$CHAIN_ID'|" "$COMPOSE_FILE"
SED_INPLACE "s|^\([[:space:]]*JWT_SECRET:\).*|\1 '$JWT_SECRET'|" "$COMPOSE_FILE"

# --------- LAUNCH DOCKER STACK ---------
echo "Starting stack..."
cd "$DOCKER_DIR"
docker compose up -d
cd ../..

echo "✅ Setup completed successfully!"
