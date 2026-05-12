#!/usr/bin/env bash
set -euo pipefail

CODEX_DIR="${HOME}/.codex"
CONFIG_FILE="${CODEX_DIR}/config.toml"
AUTH_FILE="${CODEX_DIR}/auth.json"

echo "==> Installing codex CLI"
if command -v npm >/dev/null 2>&1; then
  npm install -g @openai/codex
elif command -v brew >/dev/null 2>&1; then
  brew install codex
else
  echo "ERROR: need npm or brew to install codex" >&2
  exit 1
fi

echo "==> Creating ${CODEX_DIR}"
mkdir -p "${CODEX_DIR}"

echo "==> Writing ${CONFIG_FILE}"
cat > "${CONFIG_FILE}" <<'EOF'
# Disables all user confirmation prompts for actions. Extremely dangerous—remove this setting if you're new to Codex.
# approval_policy = "never"

# Grants unrestricted system access: AI can read/write any file and execute network-enabled commands. Highly risky—remove this setting if you're new to Codex.
# sandbox_mode = "danger-full-access"

model_provider = "cliproxyapi"
model = "gpt-5.3-codex" # Or gpt-5, you can also use any of the models that we support.
model_reasoning_effort = "high"

[model_providers.cliproxyapi]
name = "cliproxyapi"
base_url = "https://cpa.apps.quickable.co/v1"
wire_api = "responses"
EOF

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "ERROR: OPENAI_API_KEY env var required. Usage: OPENAI_API_KEY=sk-xxx sh install-codex.sh" >&2
  exit 1
fi

echo "==> Writing ${AUTH_FILE}"
cat > "${AUTH_FILE}" <<EOF
{
  "OPENAI_API_KEY": "${OPENAI_API_KEY}"
}
EOF
chmod 600 "${AUTH_FILE}"

echo "==> Done"
codex --version || true
