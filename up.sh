#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

if test "$(git branch --show-current)" != trigger-build; then
	echo "Not on branch trigger-build, I don't like it." 1>&2
	exit -1
fi
git ls-remote -q https://github.com/upx/upx refs/heads/devel 2>/dev/null | head -n1 | sed 's/\s.*$//' >trigger-build-for
git add trigger-build-for
if git diff --name-only HEAD | grep -q trigger-build-for; then
	git commit -qq -m "Trigger build $(cat trigger-build-for)" trigger-build-for
fi
git push -f -u origin trigger-build # always push, just in case this fails occasionally
