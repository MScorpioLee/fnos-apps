#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=../lib/gh-api.sh
source "$REPO_ROOT/scripts/lib/gh-api.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

CALL_LOG="$TMP_DIR/curl.args"
export CALL_LOG

cat > "$TMP_DIR/curl" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" > "$CALL_LOG"
printf '{"tag_name":"v1.2.3"}'
EOF
chmod +x "$TMP_DIR/curl"

export PATH="$TMP_DIR:$PATH"

export GH_TOKEN="test-token"
install_github_api_curl_wrapper

bash -c 'curl -sL "https://api.github.com/repos/example/project/releases/latest" >/dev/null'
if ! grep -Fxq "Authorization: Bearer test-token" "$CALL_LOG"; then
  echo "Expected Authorization header for api.github.com request" >&2
  cat "$CALL_LOG" >&2
  exit 1
fi

> "$CALL_LOG"
bash -c 'curl -sL "https://example.com/project.tar.gz" >/dev/null'
if grep -Fq "Authorization:" "$CALL_LOG"; then
  echo "Did not expect Authorization header for non-GitHub request" >&2
  cat "$CALL_LOG" >&2
  exit 1
fi

unset GH_TOKEN
> "$CALL_LOG"
bash -c 'curl -sL "https://api.github.com/repos/example/project/releases/latest" >/dev/null'
if grep -Fq "Authorization:" "$CALL_LOG"; then
  echo "Did not expect Authorization header without GH_TOKEN" >&2
  cat "$CALL_LOG" >&2
  exit 1
fi

echo "gh-api-wrapper: PASS"
