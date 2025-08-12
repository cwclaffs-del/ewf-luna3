mkdir -p scripts
cat > scripts/scaffold.sh <<'BASH'
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
log() { printf "[scaffold] %s\n" "$*"; }
mkd() { mkdir -p "$1"; log "dir   $1"; }
write_if_absent() {
  local path="$1"; shift
  if [[ -e "$path" ]]; then
    log "skip  $path (exists)"
  else
    mkdir -p "$(dirname "$path")"
    printf "%s" "$*" > "$path"
    log "file  $path"
  fi
}
chmodx() { chmod +x "$1" && log "chmod +x $1"; }

# Directories
mkd "$ROOT/bootstrap"
mkd "$ROOT/luna/profiles"
mkd "$ROOT/utils"
mkd "$ROOT/plugins"
mkd "$ROOT/storage"
mkd "$ROOT/journal"
mkd "$ROOT/docs"

# termux-setup.sh (wrapper for fresh devices; ships in repo for convenience)
write_if_absent "$ROOT/termux-setup.sh" "#!/usr/bin/env bash
set -euo pipefail

echo '[termux-setup] Checking Termux environment...'
if ! command -v pkg >/dev/null 2>&1; then
  echo 'This script is intended for Termux.' >&2
  exit 1
fi

# Storage permission (interactive on first run)
if command -v termux-setup-storage >/dev/null 2>&1; then
  termux-setup-storage || true
fi

echo '[termux-setup] Updating and installing base packages...'
yes | pkg update || true
pkg upgrade -y || true
pkg install -y git openssh curl tar unzip aria2 || true

echo '[termux-setup] Ready. If this repo is cloned, run: bash bootstrap/Bootstrap.sh'
"

chmodx "$ROOT/termux-setup.sh"

# Bootstrap.sh with flags and profile dispatch
write_if_absent "$ROOT/bootstrap/Bootstrap.sh" "#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=\"\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")/..\" && pwd)\"
LOG_DIR=\"\$ROOT_DIR/journal\"
mkdir -p \"\$LOG_DIR\"
LOG_FILE=\"\$LOG_DIR/bootstrap-\$(date +%Y%m%d-%H%M%S).log\"

log() { printf '[bootstrap] %s\n' \"\$*\" | tee -a \"\$LOG_FILE\"; }
err() { printf '[bootstrap][error] %s\n' \"\$*\" | tee -a \"\$LOG_FILE\" >&2; }
ok()  { printf '[bootstrap][ok] %s\n' \"\$*\" | tee -a \"\$LOG_FILE\"; }

MODE=\"\"
LOG_LEVEL=\"compact\"
DO_SNAPSHOT=false
DO_AUDIT=false
OFFLINE=false
RECOVER=false

usage() {
  cat <<USAGE
Usage: \$0 [options]

Options:
  --mode minimal|dev|teaching   Select setup profile
  --audit                       SSH/Git checks
  --recover                     Self-heal missing deps
  --log verbose|compact         Log verbosity (default: compact)
  --snapshot                    Create a snapshot after setup
  --offline                     Avoid network-dependent steps
  -h, --help                    Show help
USAGE
}

while [[ \${1:-} ]]; do
  case \"\$1\" in
    --mode) MODE=\"\${2:-}\"; shift 2;;
    --audit) DO_AUDIT=true; shift;;
    --recover) RECOVER=true; shift;;
    --log) LOG_LEVEL=\"\${2:-}\"; shift 2;;
    --snapshot) DO_SNAPSHOT=true; shift;;
    --offline) OFFLINE=true; shift;;
    -h|--help) usage; exit 0;;
    *) err \"Unknown option: \$1\"; usage; exit 1;;
  esac
done

# Compact vs verbose logging toggle
if [[ \"\$LOG_LEVEL\" == \"compact\" ]]; then
  set +x
else
  set -x
fi

# Preconditions / base deps
need() {
  command -v \"\$1\" >/dev/null 2>&1 || { err \"Missing dependency: \$1\"; return 1; }
}
install_fix() {
  if command -v pkg >/dev/null 2>&1; then
    pkg install -y \"\$@\" || true
  fi
}

log \"Starting bootstrap (mode=\${MODE:-none}, offline=\$OFFLINE)\"

if \"\$RECOVER\"; then
  bash \"\$ROOT_DIR/utils/fix-deps.sh\" || true
fi

if \"\$DO_AUDIT\"; then
  bash \"\$ROOT_DIR/utils/audit.sh\" || true
fi

# Dispatch to profile
case \"\$MODE\" in
  minimal)  bash \"\$ROOT_DIR/luna/profiles/minimal.sh\"  || true ;;
  dev)      bash \"\$ROOT_DIR/luna/profiles/dev.sh\"      || true ;;
  teaching) bash \"\$ROOT_DIR/luna/profiles/teaching.sh\" || true ;;
  \"\")      log \"No --mode provided. Skipping profile-specific steps.\" ;;
  *)        err \"Unknown mode: \$MODE\"; exit 2 ;;
esac

# Optional snapshot
if \"\$DO_SNAPSHOT\"; then
  bash \"\$ROOT_DIR/utils/snapshot.sh\" || true
fi

ok \"Bootstrap complete.\"
"

chmodx "$ROOT/bootstrap/Bootstrap.sh"

# Profile stubs
write_if_absent "$ROOT/luna/profiles/minimal.sh" "#!/usr/bin/env bash
set -euo pipefail
echo '[profile:minimal] Installing only essential runtime deps...'
# Example: pkg install -y clang cmake # if building local runners
"
chmodx "$ROOT/luna/profiles/minimal.sh"

write_if_absent "$ROOT/luna/profiles/dev.sh" "#!/usr/bin/env bash
set -euo pipefail
echo '[profile:dev] Installing development toolchain...'
# Example: pkg install -y git python openssh make neovim
"
chmodx "$ROOT/luna/profiles/dev.sh"

write_if_absent "$ROOT/luna/profiles/teaching.sh" "#!/usr/bin/env bash
set -euo pipefail
echo '[profile:teaching] Enabling verbose logs, examples, and sandbox...'
# Example: export LUNA_TEACHING=1
"
chmodx "$ROOT/luna/profiles/teaching.sh"

# luna.sh stub (we'll flesh this out next)
write_if_absent "$ROOT/luna/luna.sh" "#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=\"\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")/..\" && pwd)\"
MODE=\"run\"

usage() {
  cat <<USAGE
Usage: \$0 [--companion|--run]
  --companion   Launch Luna Companion mode (daily utility)
  --run         Launch standard runner
USAGE
}
case \"\${1:-}\" in
  --companion) MODE=\"companion\" ;;
  --run|\"\") MODE=\"run\" ;;
  -h|--help) usage; exit 0 ;;
  *) echo \"Unknown flag: \$1\"; usage; exit 1 ;;
esac

echo \"[luna] Mode: \$MODE\"
if [[ \"\$MODE\" == \"companion\" ]]; then
  # Placeholder: read logs, summarize changes, plan next steps
  echo \"[luna] Companion stub ready (to be implemented).\"
else
  echo \"[luna] Runner stub ready (to be implemented).\"
fi
"
chmodx "$ROOT/luna/luna.sh"

# utils: snapshot, fix-deps, audit
write_if_absent "$ROOT/utils/snapshot.sh" "#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=\"\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")/..\" && pwd)\"
OUT_DIR=\"\$ROOT_DIR/storage\"
mkdir -p \"\$OUT_DIR\"
STAMP=\$(date +%Y%m%d-%H%M%S)
ARCHIVE=\"\$OUT_DIR/ewf-luna3-\$STAMP.tgz\"
echo \"[snapshot] Creating \$ARCHIVE ...\"
tar --exclude='storage/*.tgz' -czf \"\$ARCHIVE\" -C \"\$ROOT_DIR\" .
echo \"[snapshot] Done.\"
"
chmodx "$ROOT/utils/snapshot.sh"

write_if_absent "$ROOT/utils/fix-deps.sh" "#!/usr/bin/env bash
set -euo pipefail
echo \"[fix-deps] Checking and installing missing base packages...\"
if command -v pkg >/dev/null 2>&1; then
  for p in git openssh curl tar unzip; do
    command -v \"\${p%% *}\" >/dev/null 2>&1 || pkg install -y \"\$p\" || true
  done
else
  echo \"[fix-deps] Non-Termux environment. Skipping automatic install.\"
fi
echo \"[fix-deps] Done.\"
"
chmodx "$ROOT/utils/fix-deps.sh"

write_if_absent "$ROOT/utils/audit.sh" "#!/usr/bin/env bash
set -euo pipefail
echo \"[audit] Git version: \$(git --version 2>/dev/null || echo 'missing')\"
echo \"[audit] SSH version: \$(ssh -V 2>&1 || echo 'missing')\"
if [[ -f \"\$HOME/.ssh/id_ed25519.pub\" || -f \"\$HOME/.ssh/id_rsa.pub\" ]]; then
  echo \"[audit] SSH key found.\"
else
  echo \"[audit] No SSH key. Generate with: ssh-keygen -t ed25519 -C 'device-key'\" 
fi
"
chmodx "$ROOT/utils/audit.sh"

# docs quickstart
write_if_absent "$ROOT/docs/QUICKSTART.md" "# Quickstart
- Run: \`bash termux-setup.sh\`
- Then: \`bash bootstrap/Bootstrap.sh --mode minimal --snapshot\`
- Next: \`bash luna/luna.sh --run\`
"

# Git placeholders
write_if_absent "$ROOT/plugins/.gitkeep" ""
write_if_absent "$ROOT/storage/.gitkeep" ""
write_if_absent "$ROOT/journal/.gitkeep" ""

echo
echo '[scaffold] Complete.'
echo 'Try:'
echo '  bash termux-setup.sh'
echo '  bash bootstrap/Bootstrap.sh --mode minimal --snapshot --audit'
BASH

chmod +x scripts/scaffold.sh
echo "Ready. Run: bash scripts/scaffold.sh"
