#!/bin/sh

# SPDX-License-Identifier: AGPL-3.0-only
# SPDX-FileCopyrightInfo: 2026 callmetango for XLibre
# SPDX-FileCopyrightInfo: 2026 Joseph Crowell <joseph.w.crowell@gmail.com>

set -eu


# Arguments

APP_ID="${1-$APP_ID}"


# Environment

: "${APP_ID:?APP_ID must not be empty}"
: "${APP_PRIVATE_KEY:?APP_PRIVATE_KEY must not be empty}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY must not be empty}"


# Main

privkey=$(mktemp)

trap 'rm -f "$privkey"' EXIT HUP INT TERM
printf '%s\n' "$APP_PRIVATE_KEY" > "$privkey"

b64enc() {
	openssl base64 | tr -d '=\n' | tr '/+' '_-'
}

now=$(date +%s)

header=$(printf '{"alg":"RS256","typ":"JWT"}' | b64enc)
payload=$(
	printf '{"iat":%s,"exp":%s,"iss":"%s"}' \
		"$((now - 60))" "$((now + 600))" "$APP_ID" | b64enc
)
signature=$(
	printf '%s.%s' "$header" "$payload" \
		| openssl dgst -binary -sha256 -sign "$privkey" | b64enc
)

jwt="$header.$payload.$signature"

app_slug=$(gh api --header "Authorization: Bearer $jwt" /app --jq '.slug')

install_id=$(
	gh api \
		--header "Authorization: Bearer $jwt" \
		"/repos/$GITHUB_REPOSITORY/installation" \
		--jq '.id'
)

token=$(
	gh api --method POST \
		--header "Authorization: Bearer $jwt" \
		"/app/installations/$install_id/access_tokens" \
		--jq '.token'
)

printf '%s\t%s\n' "$app_slug" "$token"
