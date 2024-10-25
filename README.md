This is the repository where I store the basic dotfiles and configurations for environment setup. The dotfile configuration bases on Dotbot.

# Installation
Note: proxy may need to be set to use Github clone and curl download Credientials may be required.

## oh-my-zsh
Zsh shall be installed for convience.
```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## dotfiles
This repository is stored on both [Github](https://github.com/KevinWu2017/.dotfiles.git) & [Gitee](https://github.com/anishathalye/dotbot.git). To use this repository:
- Github
```shell
git clone https://github.com/KevinWu2017/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git pull https://github.com/anishathalye/dotbot.git
./install
```
- Gitee
```shell
git clone https://gitee.com/kevinwu2017/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git pull https://gitee.com/winnochan/dotbot.git
./install
```

## Packages
The following command can automatically install several useful modern Unix packages.
```shell
./pkg_install.sh
ln -sf ~/.dotfiles/nvim ~/.config/nvim
```
The newly installed packages may not be awared for the autocompeletion before:
```shell
source ~/.zshrc
```

## Font
For MacOS which acts as ssh client, the nerd font can be installed.
```shell
brew install font-hack-nerd-font
```