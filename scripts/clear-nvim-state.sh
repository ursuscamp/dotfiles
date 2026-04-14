#!/usr/bin/env bash

set -euo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"

usage() {
  cat <<'EOF'
Usage: clear-nvim-state.sh [--dry-run]

Clears Neovim cache, state, and data directories, then recreates them.
EOF
}

dry_run=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      dry_run=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

remove_contents() {
  local dir="$1"

  if [[ ! -d "$dir" ]]; then
    if [[ "$dry_run" == true ]]; then
      printf 'Would create and clear: %s\n' "$dir"
      return
    fi
    mkdir -p "$dir"
    return
  fi

  if [[ "$dry_run" == true ]]; then
    printf 'Would clear: %s\n' "$dir"
    find "$dir" -mindepth 1 -maxdepth 1 -print
    return
  fi

  find "$dir" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
}

printf 'Neovim cache: %s\n' "$cache_dir"
printf 'Neovim state: %s\n' "$state_dir"
printf 'Neovim data:  %s\n' "$data_dir"

if [[ "$dry_run" == true ]]; then
  printf '\nDry run only; nothing was removed.\n'
  exit 0
fi

remove_contents "$cache_dir"
remove_contents "$state_dir"
remove_contents "$data_dir"

printf '\nNeovim cache and state have been cleared.\n'
printf 'Neovim data has been cleared too.\n'
