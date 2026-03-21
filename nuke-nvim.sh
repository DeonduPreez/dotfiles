#!/usr/bin/env bash
set -e

read -rp "Also delete lazy-lock.json? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  rm -f ~/.config/nvim/lazy-lock.json
  echo "Deleted lazy-lock.json"
fi

rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
echo "Nvim has been nuked :)"
