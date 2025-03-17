#!/bin/bash

# Define a list of packages to install
pkg_list=(
    "fzf"
    "ripgrep"
    "fd"
    "bat"
    "lsd"
    "dust"
    "lazygit"
    "lazydocker"
    "zellij"
    "neovim"
    "delta"
    "zoxide"
    "procs"
    "bottom"
    "hyperfine"
)

# Concatenate the package list into a single string
pkg_list_str=$(echo "${pkg_list[@]}")

# Use Brew to install the packages
# If -a is passed, install all packages
if [[ "$1" == "-a" ]]; then
    echo "Installing all packages"
    brew install $pkg_list_str
else
    # Otherwise, install the packages with yes or no questions
    for pkg in "${pkg_list[@]}"; do
        read -p "Install $pkg? (y/n): " choice
        if [[ "$choice" == "y" ]]; then
            echo "Installing $pkg"
            brew install "$pkg"
        fi
    done
fi