This is the repository where I store the basic dotfiles and configurations for environment setup. The dotfile configuration bases on Dotbot.

# Installation

## dotfiles
This repository is stored on both [Github](https://github.com/KevinWu2017/.dotfiles.git) & [Gitee](https://github.com/anishathalye/dotbot.git). To use this repository:
- Github
```shell
git clone https://github.com/KevinWu2017/.dotfiles.git
cd .dotfiles
git pull https://github.com/anishathalye/dotbot.git
./install
```
- Gitee
```shell
git clone https://gitee.com/kevinwu2017/.dotfiles.git
cd .dotfiles
git pull https://gitee.com/winnochan/dotbot.git
./install
```

## Packages
The following command can automatically install several useful modern Unix packages.
Note: proxy may need to be set to use Github clone & credientials may be required.
```shell
./pkg_install.sh
```