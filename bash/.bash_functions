#!/bin/bash

# ──────────────────────────────────────────────────────────────
# Universal Bash Utility Script
# Includes: Python Env Manager | AppImage Manager | Asus Profile | Tmux Manager | Misc Tools
# Author: Ghost
# Location: ~/.bash_functions
# ──────────────────────────────────────────────────────────────

# ──────────────────────────────────────────────────────────────
# PYTHON VIRTUAL ENVIRONMENT MANAGER
# ──────────────────────────────────────────────────────────────
ENV_DIR="$HOME/.env"
PYTHON_BIN="${PYTHON_BIN:-python3}"

pick() {
  local prompt="$1"

  if command -v fzf >/dev/null 2>&1; then
    fzf --prompt="$prompt > " --height=40% --reverse
  elif command -v rofi >/dev/null 2>&1 && [[ -n "$DISPLAY" ]]; then
    rofi -dmenu -p "$prompt"
  else
    select opt; do
      echo "$opt"
      break
    done
  fi
}


av() {
  [[ ! -d "$ENV_DIR" ]] && echo "No env dir: $ENV_DIR" && return 1

  mapfile -t ENV_LIST < <(find "$ENV_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)
  [[ ${#ENV_LIST[@]} -eq 0 ]] && echo "No environments found." && return 1

  SELECTED_ENV=$(printf "%s\n" "${ENV_LIST[@]}" | pick "Activate env")
  [[ -z "$SELECTED_ENV" ]] && return 1

  [[ -n "$VIRTUAL_ENV" ]] && deactivate
  source "$ENV_DIR/$SELECTED_ENV/bin/activate"
  echo "Activated: $SELECTED_ENV"
}

dv() {
  [[ -n "$VIRTUAL_ENV" ]] && deactivate && echo "Deactivated." || echo "No env active."
}

cenv() {
  local NEW_ENV

  read -rp "New environment name: " NEW_ENV
  [[ -z "$NEW_ENV" ]] && echo "No name entered." && return 1

  mkdir -p "$ENV_DIR"
  [[ -d "$ENV_DIR/$NEW_ENV" ]] && echo "Environment '$NEW_ENV' already exists." && return 1

  "$PYTHON_BIN" -m venv "$ENV_DIR/$NEW_ENV"
  echo "Created environment: $NEW_ENV"
}

denv() {
  [[ ! -d "$ENV_DIR" ]] && echo "No env dir." && return 1

  mapfile -t ENV_LIST < <(find "$ENV_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)
  [[ ${#ENV_LIST[@]} -eq 0 ]] && echo "No envs found." && return 1

  SELECTED_ENV=$(printf "%s\n" "${ENV_LIST[@]}" | pick "Delete env")
  [[ -z "$SELECTED_ENV" ]] && return 1

  CONFIRM=$(printf "No\nYes" | pick "Delete $SELECTED_ENV?")
  [[ "$CONFIRM" != "Yes" ]] && echo "Cancelled." && return 1

  rm -rf "$ENV_DIR/$SELECTED_ENV"
  echo "Deleted: $SELECTED_ENV"
}

# --------------------------------------------------
# Add AppImage
# --------------------------------------------------

APPIMAGE_BASE="$HOME/.appimage"
DESKTOP_DIR="$HOME/.local/share/applications"

addimage() {
  [[ $# -ne 1 ]] && echo "Usage: addimage <AppImage path>" && return 1

  local SRC APPIMAGE_PATH APPIMAGE_NAME FOLDER_NAME INSTALL_DIR
  SRC="$1"
  APPIMAGE_PATH="$(realpath "$SRC" 2>/dev/null)"
  [[ ! -f "$APPIMAGE_PATH" ]] && echo "File not found: $SRC" && return 1

  # Basic validation
  file "$APPIMAGE_PATH" | grep -qi appimage || {
    echo "Not a valid AppImage."
    return 1
  }

  APPIMAGE_NAME="$(basename "$APPIMAGE_PATH")"
  FOLDER_NAME="${APPIMAGE_NAME%.AppImage}"
  INSTALL_DIR="$APPIMAGE_BASE/$FOLDER_NAME"

  mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR"

  read -rp "App Name: " CUSTOM_NAME
  [[ -z "$CUSTOM_NAME" ]] && echo "Name cannot be empty." && return 1

  read -rp "Icon path (optional): " CUSTOM_ICON
  local APPIMAGE_DEST="$INSTALL_DIR/$APPIMAGE_NAME"
  local ICON_DEST="$INSTALL_DIR/icon.png"
  local DESKTOP_FILE="$DESKTOP_DIR/$FOLDER_NAME.desktop"

  echo "Installing $APPIMAGE_NAME..."
  cp "$APPIMAGE_PATH" "$APPIMAGE_DEST" || return 1
  chmod +x "$APPIMAGE_DEST"

  # ------------------------------------------------
  # Icon handling
  # ------------------------------------------------
  if [[ -n "$CUSTOM_ICON" && -f "$CUSTOM_ICON" ]]; then
    cp "$CUSTOM_ICON" "$ICON_DEST"
  else
    echo "Extracting icon..."
    (
      cd "$INSTALL_DIR" || exit 1
      "$APPIMAGE_DEST" --appimage-extract &>/dev/null
    )

    FOUND_ICON=$(find "$INSTALL_DIR/squashfs-root" \
      \( -path '*256x256*' -o -path '*128x128*' -o -iname '*icon*' \) \
      \( -iname '*.png' -o -iname '*.svg' -o -iname '*.jpg' \) \
      | head -n 1)

    if [[ -n "$FOUND_ICON" ]]; then
      cp "$FOUND_ICON" "$ICON_DEST"
    fi

    rm -rf "$INSTALL_DIR/squashfs-root"
  fi

  local ICON_LINE="Icon=${ICON_DEST:-application-default-icon}"

  # ------------------------------------------------
  # Desktop entry
  # ------------------------------------------------
  cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=$CUSTOM_NAME
Exec="$APPIMAGE_DEST"
$ICON_LINE
Comment=Installed via addimage
Terminal=false
Categories=Utility;
EOF

  chmod +x "$DESKTOP_FILE"
  echo "✔ '$CUSTOM_NAME' added to launcher."
}

# --------------------------------------------------
# Remove AppImage
# --------------------------------------------------
removeimage() {
  [[ ! -d "$DESKTOP_DIR" ]] && echo "No desktop directory found." && return 1

  local ENTRIES
  ENTRIES=$(grep -l "Installed via addimage" "$DESKTOP_DIR"/*.desktop 2>/dev/null \
    | xargs -n1 basename | sed 's/\.desktop$//')

  [[ -z "$ENTRIES" ]] && echo "No addimage apps found." && return 1

  local SELECTED
  SELECTED=$(printf "%s\n" "$ENTRIES" | pick "Remove AppImage")
  [[ -z "$SELECTED" ]] && echo "Cancelled." && return 1

  local DESKTOP_FILE="$DESKTOP_DIR/$SELECTED.desktop"
  [[ ! -f "$DESKTOP_FILE" ]] && echo "Desktop file missing." && return 1

  local INSTALL_PATH
  INSTALL_PATH=$(awk -F= '/^Exec=/{print $2}' "$DESKTOP_FILE" | sed 's/^"//;s/"$//' | xargs dirname)

  [[ "$INSTALL_PATH" != "$APPIMAGE_BASE/"* ]] && {
    echo "Refusing to delete outside $APPIMAGE_BASE"
    return 1
  }

  local CONFIRM
  CONFIRM=$(printf "No\nYes" | pick "Delete $SELECTED?")
  [[ "$CONFIRM" != "Yes" ]] && echo "Cancelled." && return 1

  rm -rf "$INSTALL_PATH" "$DESKTOP_FILE"
  echo "✔ '$SELECTED' removed."
}

# ──────────────────────────────────────────────────────────────
# QUICK SERVE (PYTHON HTTP)
# ──────────────────────────────────────────────────────────────
serve() {
  local dir="${1:-$(pwd)}"
  local port="${2:-2210}"
  local bind="${BIND_ADDR:-0.0.0.0}"
  local PYTHON_BIN="${PYTHON_BIN:-python3}"

  [[ ! -d "$dir" ]] && echo "Directory not found: $dir" && return 1

  if ss -ltn | awk '{print $4}' | grep -q ":$port$"; then
    echo "Port $port already in use"
    return 1
  fi

  local ip
  ip=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')
  ip=${ip:-localhost}

  echo "Serving $dir"
  echo "→ http://$ip:$port"

  (
    cd "$dir" || exit 1
    "$PYTHON_BIN" -m http.server "$port" --bind "$bind"
  )
}

# ──────────────────────────────────────────────────────────────
# FUZZY COMMAND HISTORY
# ──────────────────────────────────────────────────────────────
h() {
  history -a

  local cmd
  cmd=$(history | awk '{$1=""; print substr($0,2)}' \
    | tac \
    | awk '!seen[$0]++' \
    | fzf --reverse --height=50% \
          --prompt="History > " \
          --preview 'echo {}')

  [[ -z "$cmd" ]] && return

  read -rp "Run command? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || return

  fc -s "$cmd"
}

# ──────────────────────────────────────────────────────────────
# TMUX SESSION MANAGER
# ──────────────────────────────────────────────────────────────

tn() {
  local dir="$PWD"
  local base_name session_name i=1
  base_name="$(basename "$(dirname "$dir")")-$(basename "$dir" | sed 's/[^a-zA-Z0-9_-]/_/g')"
  session_name="$base_name"
  while tmux has-session -t "$session_name" 2>/dev/null; do
    session_name="${base_name}_$i"; ((i++))
  done
  tmux new-session -d -s "$session_name" -c "$dir"
  echo "Created tmux session: $session_name in $dir"
  [[ -n "$TMUX" ]] && tmux switch-client -t "$session_name" || tmux attach-session -t "$session_name"
}

tc() {
  local dir
  dir=$(zoxide query -l 2>/dev/null | fzf --prompt="Pick frequent directory: ") || true
  [[ -z "$dir" ]] && echo "No frequent directories found." && return

  local base_name session_name i=1
  base_name="$(basename "$(dirname "$dir")")-$(basename "$dir" | sed 's/[^a-zA-Z0-9_-]/_/g')"
  session_name="$base_name"
  while tmux has-session -t "$session_name" 2>/dev/null; do
    session_name="${base_name}_$i"; ((i++))
  done
  tmux new-session -d -s "$session_name" -c "$dir"
  echo "Created tmux session: $session_name in $dir"
  [[ -n "$TMUX" ]] && tmux switch-client -t "$session_name" || tmux attach-session -t "$session_name"
}

a() {
  local session
  session=$(tmux ls 2>/dev/null | fzf --prompt="Attach to session: ") || return
  local session_name
  session_name=$(echo "$session" | awk -F: '{print $1}')
  [[ -n "$TMUX" ]] && tmux switch-client -t "$session_name" || tmux attach-session -t "$session_name"
}

xx() { tmux detach; }

tl() {
  if ! tmux has-session 2>/dev/null; then
    echo -e "\033[38;5;111mNo active tmux sessions.\033[0m"
    return
  fi
  local BLUE="\033[38;5;110m" CYAN="\033[38;5;81m" GRAY="\033[38;5;240m" RESET="\033[0m"
  echo -e "${GRAY}─────────────────────────────────────────────────${RESET}"
  tmux list-sessions | while IFS= read -r line; do
    local name windows date_raw formatted_time
    name=$(echo "$line" | awk -F: '{print $1}')
    windows=$(echo "$line" | grep -o '[0-9]\+ windows')
    date_raw=$(echo "$line" | sed -E 's/.*\(created (.*)\)/\1/')
    formatted_time=$(date -d "$date_raw" +"%I:%M %p %b %d" 2>/dev/null || echo "$date_raw")
    printf "${BLUE}%-18s${RESET} ${CYAN}%-12s${RESET} ${GRAY}%s${RESET}\n" "$name" "$windows" "$formatted_time"
  done
  echo -e "${GRAY}─────────────────────────────────────────────────${RESET}"
}

# ──────────────────────────────────────────────────────────────
# Change directory
# ──────────────────────────────────────────────────────────────


# Always ignore these (never useful to cd into)
CDD_EXCLUDES=(
  ".git"
  ".cache"
  ".mozilla"
  ".npm"
  ".cargo"
  ".rustup"
  "node_modules"
  "__pycache__"
  ".local/share/Trash"
)

# Build fd exclude args
_cdd_fd_excludes() {
  for d in "${CDD_EXCLUDES[@]}"; do
    printf -- "--exclude %s " "$d"
  done
}

cdf() {
  local dir
  local SEARCH_BASE="$HOME"

  dir=$(
    fd --type d \
       --max-depth 3 \
       --hidden \
       $(_cdd_fd_excludes) \
       . "$SEARCH_BASE" 2>/dev/null \
    | grep -v '/\.' \
    | fzf --prompt="Fast cd > " \
          --height=40% \
          --reverse \
          --preview='ls -p {} | head -n 20'
  )

  [[ -z "$dir" ]] && return
  cd "$dir" || return
}

cda() {
  local dir
  local SEARCH_BASE="$HOME"

  dir=$(
    fd --type d \
       --hidden \
       $(_cdd_fd_excludes) \
       . "$SEARCH_BASE" 2>/dev/null \
    | fzf --prompt="Deep cd > " \
          --height=60% \
          --reverse \
          --preview='ls -p {} | head -n 20'
  )

  [[ -z "$dir" ]] && return
  cd "$dir" || return
}



# ──────────────────────────────────────────────────────────────
# END OF SCRIPT
# ──────────────────────────────────────────────────────────────
