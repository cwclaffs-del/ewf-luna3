cat ~/.ssh/id_ed25519.pub
ssh-keygen -t ed25519 -C "cwclaffs@gmail.com"
cat ~/.ssh/id_ed25519.pub
cd ~
nano setup_ssh_repro.sh
chmod +x setup_ssh_repro.sh
./setup_ssh_repro.sh
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com
git remote -v
git push -u origin main
git push origin v0.1.0
git remote -v
git remote set-url origin git@github.com:ewf-luna3.git
git remote -v
git push -u origin main
om:ewf-luna3.git (push)
~ $ git push -u origin main
ERROR: Repository not found.
fatal: Could not read from remote repository.
Please make sure you have the correct access rights
and the repository exists.
pkg install gh
gh auth login
pkg install gh
gh auth login
gh repo create ewf-luna3 --public --confirm
git push -u origin main
gh repo view cwclaffs-del/ewf-luna3
git remote -v
git remote set-url origin git@github.com:cwclaffs-del/ewf-luna3.git
git remote -v
git push -u origin main
gh repo view --json ruleset
git filter-repo --path .config/gh/hosts.yml --force
pkg update
pkg install git
pkg install python
pip install git-filter-repo
git filter-repo --help
git filter-repo --path .config/gh/hosts.yml --force
git push -f origin main
git remote add origin git@github.com:cwclaffs-del/ewf-luna3.git
git remote -v
git push -f origin main
git log -- .config/gh/hosts.yml
rm -rf .git
git init
git remote add origin git@github.com:cwclaffs-del/ewf-luna3.git
git add .
git commit -m "Clean re-init after secret removal"
git config --global user.name "Chris Claffey"
git config --global user.email "your-email@example.com"
git config --global user.email "cwclaffs@gmail.com"
git config --global user.name "Cwclaffs-del"
git config --list
git commit -m "Clean re-init after secret removal"
git push -f origin main
#!/data/data/com.termux/files/usr/bin/bash
# === CONFIGURE YOUR IDENTITY ===
GIT_NAME="Chris Claffey"
GIT_EMAIL="your-email@example.com"  # <-- Replace with your GitHub email
# === SETUP ===
echo "[+] Setting Git identity..."
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
echo "[+] Removing .git directory for clean re-init..."
rm -rf .git
echo "[+] Reinitializing Git repo..."
git init
echo "[+] Adding remote origin (SSH)..."
git remote add origin git@github.com:cwclaffs-del/ewf-luna3.git
echo "[+] Adding .gitignore for sensitive files..."
echo ".config/gh/hosts.yml" >> .gitignore
echo "[+] Staging all files..."
git add .
echo "[+] Committing clean state..."
git commit -m "Clean re-init after secret removal"
echo "[+] Force pushing to GitHub..."
git push -f origin main
chmod +x sanitize_push.sh
nano sanitize_push.sh
chmod +x sanitize_push.sh
./sanitize_push.sh
nano sanitize_push.shu55
exit
