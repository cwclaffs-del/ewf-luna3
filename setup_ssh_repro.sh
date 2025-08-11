#!/data/data/com.termux/files/usr/bin/bash

# === CONFIG ===
EMAIL="cwclaffs@gmail.com"
KEY_PATH="$HOME/.ssh/id_ed25519"
GITHUB_REMOTE="git@github.com:cwclaffs/envrun.git"
LOG_FILE="$HOME/ssh_setup.log"
PUBKEY_EXPORT="$HOME/id_ed25519.pub.backup"

# === INIT LOG ===
echo "📝 SSH Setup Log — $(date)" > "$LOG_FILE"

# === STEP 1: Generate SSH key if missing ===
if [ ! -f "$KEY_PATH" ]; then
    echo "🔐 Generating SSH key..." | tee -a "$LOG_FILE"
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH" -N "" | tee -a "$LOG_FILE"
else
    echo "✅ SSH key already exists at $KEY_PATH" | tee -a "$LOG_FILE"
fi

# === STEP 2: Show and export public key ===
echo -e "\n📋 Public key:" | tee -a "$LOG_FILE"
cat "${KEY_PATH}.pub" | tee -a "$LOG_FILE"

# Save a backup copy for reproducibility
cp "${KEY_PATH}.pub" "$PUBKEY_EXPORT"
echo "📦 Public key backed up to $PUBKEY_EXPORT" | tee -a "$LOG_FILE"

# === STEP 3: Set Git remote to SSH ===
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "\n🔗 Setting Git remote to SSH..." | tee -a "$LOG_FILE"
    git remote set-url origin "$GITHUB_REMOTE" | tee -a "$LOG_FILE"
else
    echo "⚠️ Not inside a Git repo — skipping remote setup." | tee -a "$LOG_FILE"
fi

# === STEP 4: Test GitHub SSH connection ===
echo -e "\n🔍 Testing SSH connection to GitHub..." | tee -a "$LOG_FILE"
ssh -T git@github.com | tee -a "$LOG_FILE"

# === DONE ===
echo -e "\n✅ SSH setup complete. Log saved to $LOG_FILE"
