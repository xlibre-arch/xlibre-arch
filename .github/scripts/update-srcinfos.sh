#!/bin/sh

# SPDX-License-Identifier: AGPL-3.0-only
# SPDX-FileCopyrightInfo: 2026 callmetango for XLibre

set -eu


# Environment

DOCKER_IMAGE="${DOCKER_IMAGE:-ghcr.io/archlinux/archlinux:latest}"
: "${APP_ID:?APP_ID must not be empty}"
: "${GH_APP_SLUG:?GH_APP_SLUG must not be empty}"

# Functions

start_container() {
	uid=$(id -u)
	docker run --detach --name arch \
		--volume "$GITHUB_WORKSPACE:/workspace" \
		"$DOCKER_IMAGE" sh -c "
			useradd -u $uid -m runner
			while : ; do sleep 3600 ; done
		"
}

cleanup() {
	docker rm --force arch >/dev/null 2>&1 || :
}


# Main

trap cleanup 0
trap 'cleanup; exit 1' HUP INT TERM

bot="${GH_APP_SLUG}[bot]"
bot_id=$(gh api "/users/$bot" --jq '.id')
started=0

gh auth setup-git
git init .
git config user.name "$bot"
git config user.email "${bot_id}+$bot@users.noreply.github.com"
git remote add origin "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY"
git fetch ${GITHUB_EVENT_BEFORE:+--depth 1} origin "$GITHUB_REF_NAME"
git checkout -B "$GITHUB_REF_NAME" FETCH_HEAD

dirs=$(mktemp)
before=${GITHUB_EVENT_BEFORE-}
git cat-file -e "$before^{commit}" 2>/dev/null ||
	before=$(git rev-list --max-parents=0 "$GITHUB_SHA")
git fetch origin "$before"
git diff --name-only "$before" "$GITHUB_SHA" | sed 's:/[^/]*$::' |
	sort -u >"$dirs"

while IFS= read -r dir; do
	test -f "$dir/PKGBUILD" || continue

	if [ $started -eq 0 ] ; then
		start_container
		started=1
	fi

	tmp=$(mktemp)
	printf 'Generating %s/.SRCINFO ... ' "$dir"
	docker exec --user runner --workdir "/workspace/$dir" arch \
		sh -c 'makepkg --printsrcinfo' >"$tmp"
	mv "$tmp" "$dir/.SRCINFO"
	printf 'done\n'
done <"$dirs"

status=$(git status --short)
printf '%s\n' "$status" | grep -q '\.SRCINFO$' || exit 0

git add -- */.SRCINFO
git commit --message 'Update .SRCINFOs'
git fetch origin "$GITHUB_REF_NAME"
git rebase "origin/$GITHUB_REF_NAME"
git push origin "$GITHUB_REF_NAME"
