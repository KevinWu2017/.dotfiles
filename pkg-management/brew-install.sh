#!/bin/bash
# check if brew is installed
if [ -n "$(command -v brew)" ]; then
  echo "brew is already installed, skip installation"
  exit 0
fi

export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_INSTALL_FROM_API=1

git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git brew-install
/bin/bash brew-install/install.sh
rm -rf brew-install

test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

test -r ~/.bashrc && echo -e "\neval \"\$($(brew --prefix)/bin/brew shellenv)\"" >>~/.bashrc
test -r ~/.zshrc && echo -e "\neval \"\$($(brew --prefix)/bin/brew shellenv)\"" >>~/.zshrc
