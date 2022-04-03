#!/bin/bash

sudo pacman -Sy --needed \
	xorg xorg-xinit lightdm \
	i3-gaps rofi \
	powerline-fonts ttf-font-awesome \
	alsa-lib alsa-utils pavucontrol pulseaudio-alsa \
	fzf zsh ranger mupdf scrot unzip unrar stow xss-lock \
	kitty \
	vim yarn npm git docker docker-compose kubectl

cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd

yay -S --needed --noconfirm neovim-git picom-jonaburg-git polybar-git i3lock-fancy-multimonitor lightdm-webkit-theme-aether

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/kita99/dotfiles && cd dotfiles && stow -S picom i3-gaps nvim kitty polybar rofi zsh
