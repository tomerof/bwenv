#!/bin/bash
set -e

mkdir -p ~/.bwenv
curl -sL https://raw.githubusercontent.com/tomerof/bwenv/refs/heads/master/bwenv.sh -o ~/.bwenv/bwenv
chmod +x ~/.bwenv/bwenv

if ! grep -q 'export PATH="$HOME/.bwenv:$PATH"' ~/.bashrc; then
  echo 'export PATH="$HOME/.bwenv:$PATH"' >> ~/.bashrc
  echo "Added bwenv to PATH. Reload your terminal or run: source ~/.bashrc"
fi

echo "✅ bwenv installed! Run 'bwenv help' to get started."
