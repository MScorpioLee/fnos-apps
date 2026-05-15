#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

TAG=$(curl -sL "https://api.github.com/repos/agentscope-ai/CoPaw/releases/latest" | \
  jq -r '.tag_name')

if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
else
  VERSION=$(echo "$TAG" | sed 's/^v//')
fi

[ -z "$VERSION" ] || [ "$VERSION" = "null" ] && { echo "Failed to resolve version for copaw" >&2; exit 1; }

# Upstream CoPaw publishes only :latest and :pre on Docker Hub (no per-version
# tags for v1.1.x and onward; see https://hub.docker.com/r/agentscope/copaw/tags).
# Numbered GitHub releases like v1.1.7 have NO matching docker image, so our
# previously published version-pinned fpks (#140) failed at \`docker pull\` on user
# NAS. Strategy: track upstream version for fpk traceability but let the docker
# image float to :latest (the upstream-recommended runtime tag).
# Warn (not fail) when the version's own docker tag is missing so maintainers
# notice if upstream switches back to version-pinned tags.
DOCKER_IMAGE="agentscope/copaw"
if ! curl -sSL --fail "https://hub.docker.com/v2/repositories/${DOCKER_IMAGE}/tags/v${VERSION}/" >/dev/null 2>&1 && \
   ! curl -sSL --fail "https://hub.docker.com/v2/repositories/${DOCKER_IMAGE}/tags/${VERSION}/" >/dev/null 2>&1; then
  echo "[INFO] No docker tag for ${DOCKER_IMAGE}:v${VERSION} or :${VERSION}; docker-compose will use :latest per upstream convention (issue #140)." >&2
fi

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
