#!/bin/bash

# Define nested associative arrays for repositories and their patterns
declare -A common_patterns=(
  [darwin_aarch64]="aarch64-apple-darwin"
  [linux_x86_64]="x86_64-unknown-linux-gnu"
  [linux_aarch64]="aarch64-unknown-linux-gnu"
)

# Top-level associative array linking repositories to their nested pattern arrays
declare -A REPOS_PATTERNS=(
  ["dandavison/delta"]="common_patterns"
  ["sharkdp/bat"]="common_patterns"
  ["lsd-rs/lsd"]="common_patterns"
  ["bootandy/dust"]="common_patterns"
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
    grep -m 1 -E "browser_download_url.*$PATTERN" | \
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
    tar -xzf "$DEST_PATH" -C ./pkg
    EXTRACTED_DIR=$(tar -tf "$DEST_PATH" | head -n 1 | cut -f1 -d"/")
    echo "Extraction complete: ./pkg/$EXTRACTED_DIR"

    # create the target directory ~/.local/bin/ (if it doesn't exist)
    mkdir -p ~/.local/bin/

    # Find executable files in the extracted directory and copy them to ~/.local/bin/ (force overwrite)
    find "./pkg/$EXTRACTED_DIR" -type f -executable -exec cp -f {} ~/.local/bin/ \;

    echo "Copied executables to ~/.local/bin/"
  else
    echo "$FILE_NAME is not a .tar.gz file, skipping extraction."
  fi
}

# Create the package directory if it doesn't exist
mkdir -p ./pkg

# Loop over the repositories and download the appropriate assets
for REPO in "${!REPOS_PATTERNS[@]}"; do
  PATTERN=$(get_pattern_for_repo "$REPO")
  install_latest_release "$REPO" "$PATTERN"
done

source ~/.zshrc