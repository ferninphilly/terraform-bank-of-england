#!/bin/bash

# --- create_keys.sh ---
# Description: Generates an SSH public/private key pair and stores them in the ./keys directory.

KEY_DIR="./keys"
KEY_NAME="azure-vm-key"
FULL_KEY_PATH="$KEY_DIR/$KEY_NAME"

# 1. Create the keys directory if it doesn't exist
if [ ! -d "$KEY_DIR" ]; then
    echo "Creating directory: $KEY_DIR"
    mkdir -p "$KEY_DIR"
    # Set restrictive permissions (optional, but good practice)
    chmod 700 "$KEY_DIR"
fi

echo "Generating SSH key pair..."

# 2. Generate the RSA key pair
# -t rsa: Key type is RSA
# -b 4096: Key bit length is 4096 (strong)
# -f $FULL_KEY_PATH: Output file path
# -N "": Creates the key without a passphrase (for simple lab use)
ssh-keygen -t rsa -b 4096 -f "$FULL_KEY_PATH" -N ""

# 3. Inform the user of the created files
if [ -f "$FULL_KEY_PATH" ] && [ -f "$FULL_KEY_PATH.pub" ]; then
    echo "----------------------------------------------------"
    echo "Success! SSH Key Pair Generated and Saved."
    echo "Private Key (Keep Secret): $FULL_KEY_PATH"
    echo "Public Key (Used in main.tf): $FULL_KEY_PATH.pub"
    echo "----------------------------------------------------"
else
    echo "Error: Key generation failed."
    exit 1
fi