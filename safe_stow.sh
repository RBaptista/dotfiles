#!/usr/bin/env bash
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for pkg in "$@"; do
    echo "=== $pkg ==="
    live="$HOME/.config/$pkg"
    repo_flat_check=$(find "$DOTFILES_DIR/$pkg" -maxdepth 1 -type f 2>/dev/null)

    if [[ -n "$repo_flat_check" ]]; then
        echo "  Removing stray flat files in repo package:"
        echo "$repo_flat_check" | sed 's/^/    /'
        find "$DOTFILES_DIR/$pkg" -maxdepth 1 -type f -delete
    fi

    if [[ -L "$live" ]]; then
        target=$(readlink -f "$live")
        if [[ "$target" == "$DOTFILES_DIR/$pkg/.config/$pkg" ]]; then
            echo "  Already correctly symlinked, skipping."
            continue
        else
            echo "  SKIP: $live is a symlink but points somewhere unexpected: $target"
            echo "        Not touching it — investigate manually."
            continue
        fi
    elif [[ ! -e "$live" ]]; then
        echo "  Nothing at $live, safe to stow directly."
    elif [[ -d "$live" ]]; then
        repo_target="$DOTFILES_DIR/$pkg/.config/$pkg"
        if diff -rq "$live" "$repo_target" >/dev/null 2>&1; then
            echo "  Live dir matches repo exactly, removing live copy and stowing."
            rm -rf "$live"
        else
            echo "  SKIP: $live differs from $repo_target. Diff:"
            diff -rq "$live" "$repo_target" 2>&1 | sed 's/^/    /'
            echo "        Not touching it — resolve the diff manually, then re-run."
            continue
        fi
    else
        echo "  SKIP: $live exists but isn't a directory or symlink. Investigate manually."
        continue
    fi

    stow -v -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
    echo "  Result: $(readlink -f "$live")"
    echo ""
done
