#!/bin/sh

# SPDX-License-Identifier: AGPL-3.0-only
# SPDX-FileCopyrightInfo: 2026 callmetango for XLibre

set -eu


# Environment

DOCKER_IMAGE="${DOCKER_IMAGE:-ghcr.io/archlinux/archlinux:latest}"
: "${APP_ID:?APP_ID must not be empty}"
: "${GH_APP_SLUG:?GH_APP_SLUG must not be empty}"
: "${PACKAGE_FEATURES?PACKAGE_FEATURES must be defined}"
: "${TARGET_BRANCH:?TARGET_BRANCH must not be empty}"


# Functions

start_container() {
	printf 'Starting Docker container'
	docker run --detach --name builder \
		--volume "$GITHUB_WORKSPACE:/workspace" \
		"$DOCKER_IMAGE" sh -c 'while :; do sleep 3600; done'
	docker exec builder sh -c "
		set -eu
		useradd -u $(id -u) -m runner
	"
	started=1
}

cleanup() {
	docker rm --force builder >/dev/null 2>&1 || :
}


# Main

trap cleanup 0
trap 'cleanup; exit 1' HUP INT TERM

before=${GITHUB_EVENT_BEFORE-}
test "$before" = '0000000000000000000000000000000000000000' && before=

bot="${GH_APP_SLUG}[bot]"
bot_id=$(gh api "/users/$bot" --jq '.id')
started=0

gh auth setup-git
git init .
git config user.name "$bot"
git config user.email "${bot_id}+$bot@users.noreply.github.com"
git remote add origin "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY"

git fetch --depth 1 origin ${before:+"$before"} "$TARGET_BRANCH"
git checkout -B "$TARGET_BRANCH" "origin/$TARGET_BRANCH"

dirs=$(mktemp)
test -n "$before" && git diff --name-only "$before" HEAD >"$dirs"
test -z "$before" && git ls-files '*/PKGBUILD' PKGBUILD >"$dirs"
sed 's:/[^/]*$::' "$dirs" | sort -u >"$dirs"-unique

while IFS= read -r dir; do
	test -f "$dir/PKGBUILD" || continue
	test $started -eq 0 && start_container

	printf 'Generating %s/.SRCINFO ... ' "$dir"
	docker exec --user runner --workdir "/workspace/$dir" builder \
		sh -c 'makepkg --printsrcinfo ${1:-} > .SRCINFO' sh "${PACKAGE_FEATURES}"
	printf 'done\n'
done <"$dirs"-unique

git add -- */.SRCINFO
git diff --cached --quiet && exit 0

git commit --message 'Update .SRCINFOs'
git fetch origin "$TARGET_BRANCH"
git rebase "origin/$TARGET_BRANCH"
git push origin "$TARGET_BRANCH"
