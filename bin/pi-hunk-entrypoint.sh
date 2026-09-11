#!/usr/bin/env bash

set -euo pipefail

RELAY_SCRIPT="/tmp/pi-tcp-relay.mjs"
RELAY_LOG="/tmp/pi-hunk-container-relay.log"

export LISTEN_PORT="${HUNK_CONTAINER_RELAY_PORT:-47657}"

LISTEN_HOST="127.0.0.1" \
TARGET_HOST="${HUNK_RELAY_TARGET_HOST:-host.docker.internal}" \
TARGET_PORT="${HUNK_RELAY_TARGET_PORT:-47658}" \
node "$RELAY_SCRIPT" \
  >"$RELAY_LOG" 2>&1 &

relay_pid=$!

relay_ready=0

for attempt in $(seq 1 50); do
  if ! kill -0 "$relay_pid" 2>/dev/null; then
    break
  fi

  if node - <<'NODE' >/dev/null 2>&1
try {
  const response = await fetch(
    `http://127.0.0.1:${process.env.LISTEN_PORT}/health`,
    { signal: AbortSignal.timeout(1000) },
  );

  const body = await response.json();

  process.exit(
    response.ok && body?.ok === true
      ? 0
      : 1
  );
} catch {
  process.exit(1);
}
NODE
  then
    relay_ready=1
    break
  fi

  sleep 0.1
done

if [[ "$relay_ready" -ne 1 ]]; then
  echo "Could not connect the container to Hunk." >&2

  if [[ -s "$RELAY_LOG" ]]; then
    echo >&2
    cat "$RELAY_LOG" >&2
  fi

  exit 1
fi

# The container runtime will terminate the relay when Pi exits.
exec pi "$@"
