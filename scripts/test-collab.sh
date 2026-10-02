#!/usr/bin/env bash
set -Eeuo pipefail

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$*"; }

source_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/review-game-collab-test.XXXXXX")"
trap 'rm -rf "$tmp_root"' EXIT

git init --bare "$tmp_root/remote.git" >/dev/null
git -C "$tmp_root/remote.git" symbolic-ref HEAD refs/heads/main
git init -b main "$tmp_root/seed" >/dev/null
git -C "$tmp_root/seed" config user.name "Collab Test"
git -C "$tmp_root/seed" config user.email "collab-test@example.invalid"
mkdir -p "$tmp_root/seed/scripts"
cp "$source_root/scripts/collab" "$tmp_root/seed/scripts/collab"
printf 'one\n' >"$tmp_root/seed/state.txt"
git -C "$tmp_root/seed" add state.txt scripts/collab
git -C "$tmp_root/seed" commit -m seed >/dev/null
git -C "$tmp_root/seed" remote add origin "$tmp_root/remote.git"
git -C "$tmp_root/seed" push -u origin main >/dev/null

git clone "$tmp_root/remote.git" "$tmp_root/canonical" >/dev/null 2>&1
git -C "$tmp_root/canonical" config user.name "Collab Test"
git -C "$tmp_root/canonical" config user.email "collab-test@example.invalid"

printf 'two\n' >"$tmp_root/seed/state.txt"
git -C "$tmp_root/seed" add state.txt
git -C "$tmp_root/seed" commit -m advance >/dev/null
git -C "$tmp_root/seed" push origin main >/dev/null
remote_head="$(git -C "$tmp_root/seed" rev-parse HEAD)"

printf 'preserve me\n' >"$tmp_root/canonical/unknown.txt"
before="$(git -C "$tmp_root/canonical" rev-parse HEAD)"
if (cd "$tmp_root/canonical" && HOME="$tmp_root/home" ./scripts/collab sync-main) >/dev/null 2>&1; then
  fail "sync-main accepted a dirty canonical checkout"
fi
[[ -f "$tmp_root/canonical/unknown.txt" ]] || fail "dirty-state guard removed an unknown file"
[[ "$(git -C "$tmp_root/canonical" rev-parse HEAD)" == "$before" ]] || \
  fail "dirty-state guard moved main"
pass "dirty canonical main is preserved"

rm "$tmp_root/canonical/unknown.txt"
(cd "$tmp_root/canonical" && HOME="$tmp_root/home" ./scripts/collab sync-main) >/dev/null
[[ "$(git -C "$tmp_root/canonical" rev-parse HEAD)" == "$remote_head" ]] || \
  fail "clean canonical main did not fast-forward"
pass "clean canonical main fast-forwards"

if grep -R -nE '(reset --hard|push[^#]*--force|checkout -- (ours|theirs))' \
  "$source_root/scripts/collab" "$source_root/.github" >/dev/null; then
  fail "destructive Git operation found in collaboration automation"
fi
pass "automation contains no destructive Git shortcuts"

printf 'All collaboration tests passed.\n'
