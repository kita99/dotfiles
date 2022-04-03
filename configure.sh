#!/bin/bash

sudo chsh -s $(which zsh)
cd ~/dotfiles && stow -S \
	autorandr i3-gaps kitty nvim \
	p10k picom polybar rofi xinit zsh \
	&& cd -
