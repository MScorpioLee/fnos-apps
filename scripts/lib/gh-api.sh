#!/bin/bash
# Shared helpers for GitHub API access with retry + auth.
#
# Source this file; do not exec.
#   source "$REPO_ROOT/scripts/lib/gh-api.sh"
#
# Provides:
#   gh_curl <url>           - curl with retry, auth, sane timeouts, --fail
#   gh_latest_tag <repo>    - shortcut for /releases/latest .tag_name
#   install_github_api_curl_wrapper
#                            - export a curl wrapper for child bash scripts
#
# Why this exists:
#   The reusable-build-app.yml 'Get Latest Version' step fans out across
#   100+ apps. Each does its own curl to api.github.com. Without
#   Authorization, GitHub Actions runners share the same IP-based 60/hour
#   anonymous quota across the whole org — easy to exhaust on a daily
#   matrix build. Symptoms: 'jq -r .tag_name' returns 'null' or an error
#   string, the script exits 1, and a perfectly fine app fails CI for
#   reasons unrelated to its own code (e.g. lucky / librechat / copyparty
#   / nextcloud / medusa / prometheus historic failures).
#
# With GH_TOKEN, the limit is 1000/hour per repo — far above what daily
# matrix builds need.

[ -n "${_GH_API_LOADED:-}" ] && return 0
_GH_API_LOADED=1

# gh_curl <url>
#   Fetches a URL with:
#     - Accept: application/vnd.github+json
#     - X-GitHub-Api-Version: 2022-11-28
#     - User-Agent: fnos-apps-ci
#     - Authorization: Bearer $GH_TOKEN    (if GH_TOKEN is set)
#     - --retry 5 --retry-delay 5 --retry-all-errors
#     - --connect-timeout 30 --max-time 60
#     - --fail (HTTP >= 400 → non-zero exit)
#
# Echoes response body. Returns curl's exit code.
gh_curl() {
    local url="${1:?gh_curl requires <url>}"
    local headers=(
        -H "Accept: application/vnd.github+json"
        -H "X-GitHub-Api-Version: 2022-11-28"
        -H "User-Agent: fnos-apps-ci"
    )
    if [ -n "${GH_TOKEN:-}" ]; then
        headers+=(-H "Authorization: Bearer $GH_TOKEN")
    fi
    curl --silent --location --fail \
         --retry 5 --retry-delay 5 --retry-all-errors \
         --connect-timeout 30 --max-time 60 \
         "${headers[@]}" \
         "$url"
}

# gh_latest_tag <owner/repo>
#   Fetches /releases/latest and prints .tag_name.
#   Exit 1 (and prints to stderr) if the API returns no tag_name.
gh_latest_tag() {
    local repo="${1:?gh_latest_tag requires owner/repo}"
    local body tag
    if ! body="$(gh_curl "https://api.github.com/repos/${repo}/releases/latest")"; then
        echo "gh_latest_tag: failed to fetch /releases/latest for ${repo}" >&2
        return 1
    fi
    tag="$(printf '%s' "$body" | jq -r '.tag_name // empty')"
    if [ -z "$tag" ] || [ "$tag" = "null" ]; then
        echo "gh_latest_tag: ${repo} /releases/latest returned no tag_name" >&2
        printf '%s' "$body" | head -c 200 >&2
        echo "" >&2
        return 1
    fi
    printf '%s' "$tag"
}

# gh_releases <owner/repo>
#   Fetches /releases and prints the full JSON array body.
#   Use this when you need to filter releases yourself
#   (e.g. exclude release candidates, find a specific version pattern).
gh_releases() {
    local repo="${1:?gh_releases requires owner/repo}"
    gh_curl "https://api.github.com/repos/${repo}/releases"
}

_github_api_curl_passthrough() {
    local args=("$@")
    local arg next url
    local has_accept=0
    local has_api_version=0
    local has_auth=0
    local has_user_agent=0

    local i
    for ((i = 0; i < ${#args[@]}; i++)); do
        arg="${args[$i]}"
        next="${args[$((i + 1))]:-}"

        case "$arg" in
            https://api.github.com/*)
                url="$arg"
                ;;
            --url)
                if [[ "$next" == https://api.github.com/* ]]; then
                    url="$next"
                fi
                ;;
            --url=https://api.github.com/*)
                url="${arg#--url=}"
                ;;
            -H|--header)
                case "$next" in
                    Accept:*|accept:*) has_accept=1 ;;
                    Authorization:*|authorization:*) has_auth=1 ;;
                    User-Agent:*|user-agent:*) has_user_agent=1 ;;
                    X-GitHub-Api-Version:*|x-github-api-version:*) has_api_version=1 ;;
                esac
                ;;
            -HAccept:*|-Haccept:*) has_accept=1 ;;
            -HAuthorization:*|-Hauthorization:*) has_auth=1 ;;
            -HUser-Agent:*|-Huser-agent:*) has_user_agent=1 ;;
            -HX-GitHub-Api-Version:*|-Hx-github-api-version:*) has_api_version=1 ;;
        esac
    done

    if [ -z "${url:-}" ]; then
        command curl "$@"
        return
    fi

    local headers=()
    [ "$has_accept" -eq 0 ] && headers+=(-H "Accept: application/vnd.github+json")
    [ "$has_api_version" -eq 0 ] && headers+=(-H "X-GitHub-Api-Version: 2022-11-28")
    [ "$has_user_agent" -eq 0 ] && headers+=(-H "User-Agent: fnos-apps-ci")
    if [ -n "${GH_TOKEN:-}" ] && [ "$has_auth" -eq 0 ]; then
        headers+=(-H "Authorization: Bearer $GH_TOKEN")
    fi

    command curl --fail \
         --retry 5 --retry-delay 5 --retry-all-errors \
         --connect-timeout 30 --max-time 60 \
         "${headers[@]}" \
         "$@"
}

# install_github_api_curl_wrapper
#   Exports a Bash function named "curl" so child bash scripts that still call
#   api.github.com directly inherit GH_TOKEN authentication without changing
#   ordinary non-GitHub downloads.
install_github_api_curl_wrapper() {
    curl() {
        _github_api_curl_passthrough "$@"
    }
    export -f _github_api_curl_passthrough
    export -f curl
}
