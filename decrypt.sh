#!/bin/bash
# decrypt.sh
read -sp "Enter password: " password
openssl aes-256-cbc -d -a -salt -pbkdf2 -in dotfiles/alias_encrypted -out dotfiles/alias_decrypted -k "$password"

set -e

CONFIG="install.conf.alias.yaml"
DOTBOT_DIR="dotbot"

DOTBOT_BIN="bin/dotbot"
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#cd "${BASEDIR}"
#git -C "${DOTBOT_DIR}" submodule sync --quiet --recursive
#git submodule update --init --recursive "${DOTBOT_DIR}"

"${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "${CONFIG}" "${@}"