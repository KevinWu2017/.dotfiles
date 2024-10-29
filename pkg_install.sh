#!/bin/bash

# Define nested associative arrays for repositories and their patterns
declare -A common_patterns=(
  [darwin_aarch64]="aarch64-apple-darwin"
  [linux_x86_64]="x86_64-unknown-linux-gnu"
  [linux_aarch64]="aarch64-unknown-linux-gnu"
)

declare -A lazygit_patterns=(
  [darwin_aarch64]="Darwin_arm64"
  [linux_x86_64]="Linux_x86_64"
  [linux_aarch64]="Linux_arm64"
)

declare -A zellij_patterns=(
  [darwin_aarch64]="aarch64-apple-darwin"
  [linux_x86_64]="x86_64-unknown-linux-musl"
  [linux_aarch64]="aarch64-unknown-linux-musl"
)

declare -A nvim_patterns=(
  [darwin_aarch64]="macos-arm64"
  [linux_x86_64]="linux64"
  [linux_aarch64]="Not Supported"
)

# Top-level associative array linking repositories to their nested pattern arrays
declare -A REPOS_PATTERNS=(
  ["dandavison/delta"]="common_patterns"
  ["sharkdp/bat"]="common_patterns"
  ["lsd-rs/lsd"]="common_patterns"
  ["bootandy/dust"]="common_patterns"
  ["jesseduffield/lazygit"]="lazygit_patterns"
  ["zellij-org/zellij"]="zellij_patterns"
  ["neovim/neovim"]="nvim_patterns"
)

# Determine the current OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Normalize architecture naming
case "$ARCH" in
  "x86_64") ARCH="x86_64" ;;
  "aarch64" | "arm64") ARCH="aarch64" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Helper function to fetch the pattern for a given repo
get_pattern_for_repo() {
  local REPO=$1
  local KEY="${OS}_${ARCH}"

  # Get the name of the nested pattern array for the given repo
  local PATTERN_MAP_NAME=${REPOS_PATTERNS[$REPO]}

  # Use indirect expansion to access the nested associative array
  declare -n PATTERN_MAP="$PATTERN_MAP_NAME"
  local PATTERN="${PATTERN_MAP[$KEY]}"

  if [[ -z "$PATTERN" ]]; then
    echo "No matching pattern found for $REPO on $OS with $ARCH architecture."
    exit 1
  fi

  echo "$PATTERN"
}

# Helper function to install the latest release for a repository
install_latest_release() {
  local REPO=$1
  local PATTERN=$2

  echo "Fetching latest release for $REPO ..."

  # Fetch the latest release from the GitHub API
  LATEST_RELEASE=$(curl --silent "https://api.github.com/repos/$REPO/releases/latest")

  # Extract the download URL matching the pattern
  DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | \
    grep -E "browser_download_url.*$PATTERN" | \
    grep -v "sha256sum" | \
    sed -n 's/.*"\(https[^"]*\)".*/\1/p')

  if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "No matching asset found for $REPO with pattern: $PATTERN"
    exit 1
  fi

  # Extract the file name and download the asset
  FILE_NAME=$(basename "$DOWNLOAD_URL")
  DEST_PATH="./pkg/$FILE_NAME"
  echo "Downloading $FILE_NAME from $DOWNLOAD_URL to $DEST_PATH ..."
  curl -L -o "$DEST_PATH" "$DOWNLOAD_URL"

  echo "Download complete: $FILE_NAME"

  # If file type is .tar.gz，extract the contents
  if [[ "$FILE_NAME" == *.tar.gz ]]; then
    echo "Extracting $FILE_NAME ..."
    EXTRACTED_DIR=$(tar -tf "$DEST_PATH" | head -n 1 | cut -f1 -d"/")
    TARGET_EXTRACTED_DIR=$(echo "$FILE_NAME" | sed 's/\.tar\.gz$//')
    if [[ "$EXTRACTED_DIR" == "$TARGET_EXTRACTED_DIR" ]]; then
      tar -xzf "$DEST_PATH" -C ./pkg
    else
      EXTRACTED_DIR=$TARGET_EXTRACTED_DIR
      mkdir -p ./pkg/$EXTRACTED_DIR
      tar -xzf "$DEST_PATH" -C ./pkg/$EXTRACTED_DIR
    fi
    echo "Extraction complete: ./pkg/$TARGET_EXTRACTED_DIR"

    # Find executable files in the extracted directory and copy them to ~/.local/bin/ (force overwrite)
    find "./pkg/$EXTRACTED_DIR" -type f -executable ! -name "*.sh" | while read -r EXECUTABLE; do
      LINK_NAME="$HOME/.local/bin/$(basename "$EXECUTABLE")"
      FULL_PATH="$(pwd)/$EXECUTABLE"
      echo "Creating symlink: $LINK_NAME -> $FULL_PATH"
      ln -sf "$FULL_PATH" "$LINK_NAME"
    done

    echo "Copied executables to ~/.local/bin/"
  else
    echo "$FILE_NAME is not a .tar.gz file, skipping extraction."
  fi
}

# Create the package directory if it doesn't exist
mkdir -p ./pkg
# create the target directory ~/.local/bin/ (if it doesn't exist)
mkdir -p ~/.local/bin/

# Loop over the repositories and download the appropriate assets
for REPO in "${!REPOS_PATTERNS[@]}"; do
  echo "=============================================================================="
  read -p "Do you want to install the latest release for $REPO? (y/n) " choice
  case "$choice" in 
    y|Y ) 
      PATTERN=$(get_pattern_for_repo "$REPO")
      install_latest_release "$REPO" "$PATTERN"
      ;;
    n|N ) 
      echo "Skipping $REPO"
      ;;
    * ) 
      echo "Invalid choice. Skipping $REPO"
      ;;
  esac
done
