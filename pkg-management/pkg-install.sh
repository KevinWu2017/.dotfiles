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

# 定义函数以更新 ~/.zshrc（添加zoxide初始化语句）
update_zshrc_for_zoxide() {
    if ! grep -q 'zoxide init zsh' ~/.zshrc; then
        echo -e "\n# Initialize zoxide\neval \"\$(zoxide init zsh)\"" >> ~/.zshrc
        echo "Updated ~/.zshrc with zoxide initialization."
    fi
}

# Use Brew to install the packages
# If -a is passed, install all packages
if [[ "$1" == "-a" ]]; then
    echo "Installing all packages"
    brew install $pkg_list_str
    # 更新zshrc
    update_zshrc_for_zoxide
else
    # Otherwise, install the packages with yes or no questions
    for pkg in "${pkg_list[@]}"; do
        read -p "Install $pkg? (y/n): " choice
        if [[ "$choice" == "y" ]]; then
            echo "Installing $pkg"
            brew install "$pkg"
            # 如果安装的是zoxide，则调用函数更新~/.zshrc
            if [[ "$pkg" == "zoxide" ]]; then
                update_zshrc_for_zoxide
            fi
        fi
    done
fi