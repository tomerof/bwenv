#!/usr/bin/env bash

# Cross-platform bwenv CLI tool
# Dependencies: bw (Bitwarden CLI), jq, sed, cat

set -e

# Default .env mode and item name
ENV_MODE=".env"
DIR_NAME=$(basename "$PWD")
BWENV_ITEM_NAME="bwenv-${DIR_NAME}-${ENV_MODE}"

function help_text() {
  echo "\nUsage: bwenv <command> [env_mode]"
  echo "\nCommands:"
  echo "  login                     Log in to Bitwarden"
  echo "  save [env_mode]          Save a .env file (default: .env)"
  echo "  load [env_mode]          Load from Bitwarden to local .env file"
  echo "  update [env_mode]        Update an existing Bitwarden entry"
  echo "  set-name <custom_name>   Override the Bitwarden item name"
  echo "  help                     Show this help text"
  echo
}

function login() {
  bw login || true
  export BW_SESSION=$(bw unlock --raw)
}

function set_env_mode() {
  ENV_MODE="${1:-.env}"
  BWENV_ITEM_NAME="bwenv-${DIR_NAME}-${ENV_MODE}"
}

function set_name() {
  BWENV_ITEM_NAME="$1"
  echo "Item name manually set to: $BWENV_ITEM_NAME"
}

function save_env() {
  set_env_mode "$1"
  local file="$ENV_MODE"
  if [ ! -f "$file" ]; then
    echo "File '$file' not found."
    exit 1
  fi

  login
  local content=$(cat "$file" | sed ':a;N;$!ba;s/\n/\\n/g')
  bw create item "{\"type\":2,\"name\":\"$BWENV_ITEM_NAME\",\"notes\":\"$content\"}" > /dev/null
  echo "Saved '$file' to Bitwarden as '$BWENV_ITEM_NAME'"
}

function load_env() {
  set_env_mode "$1"
  local file="$ENV_MODE"
  login
  local content=$(bw get notes "$BWENV_ITEM_NAME")
  echo -e "$content" > "$file"
  echo "Loaded Bitwarden item '$BWENV_ITEM_NAME' into '$file'"
}

function update_env() {
  set_env_mode "$1"
  local file="$ENV_MODE"
  if [ ! -f "$file" ]; then
    echo "File '$file' not found."
    exit 1
  fi
  login
  local content=$(cat "$file" | sed ':a;N;$!ba;s/\n/\\n/g')
  local item_id=$(bw list items --search "$BWENV_ITEM_NAME" | jq -r '.[0].id')
  bw edit item "$item_id" "{\"notes\":\"$content\"}" > /dev/null
  echo "Updated Bitwarden item '$BWENV_ITEM_NAME' with contents of '$file'"
}

case "$1" in
  login)
    login
    ;;
  save)
    save_env "$2"
    ;;
  load)
    load_env "$2"
    ;;
  update)
    update_env "$2"
    ;;
  set-name)
    set_name "$2"
    ;;
  help|--help|-h|"")
    help_text
    ;;
  *)
    echo "Unknown command: $1"
    help_text
    exit 1
    ;;
esac
