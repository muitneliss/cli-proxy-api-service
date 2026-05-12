# tini-cli-proxy-api

CLI Proxy API deployment + Codex CLI installer pointing at the proxy.

## Components

- `config.yaml` — proxy server config (edit `api-keys` list directly)
- `docker-compose.yml` — runs `eceasy/cli-proxy-api:latest` with `config.yaml` mounted read-only
- `install-codex.sh` — installs `@openai/codex` and wires it to the proxy upstream

## Run proxy

```bash
docker compose up -d
```

Edit `api-keys` in `config.yaml` before deploy. Auth state persists in named volume `cli-proxy-api-auth`. Server listens on `0.0.0.0:8317`. Management key bcrypt-hashed under `remote-management.secret-key`.

## Install Codex CLI

```bash
OPENAI_API_KEY=sk-xxx sh install-codex.sh
```

Writes:
- `~/.codex/config.toml` — provider `cliproxyapi`, base URL `https://cpa.apps.quickable.co/v1`, model `gpt-5.3-codex`
- `~/.codex/auth.json` — `{ "OPENAI_API_KEY": "..." }`, mode `600`

Requires `npm` or `brew`. Fails fast if `OPENAI_API_KEY` env var missing.

## Config notes

- API keys: set `API_KEYS` in `.env` (comma-separated); injected into `api-keys` list at container boot
- Provider keys: `gemini-api-key`, `codex-api-key`, `claude-api-key`, `vertex-api-key`, `openai-compatibility`
- Routing strategy: `round-robin` (default) or `fill-first`
- Session affinity: off by default; toggle `routing.session-affinity`
- TLS: off by default; set `tls.enable: true` + cert/key paths
