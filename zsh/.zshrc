# Print a noice custom banner
cat ~/ASCIIArt/kita

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --------- ZSH Core ------------
export ZSH="/home/kita/.oh-my-zsh"
export NVM_LAZY_LOAD=true
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    docker
    docker-compose
    zsh-nvm
    aws
)
source $ZSH/oh-my-zsh.sh
# --------- ZSH Core ------------

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.yarn/bin:$HOME/.poetry/bin:$HOME/.local/share/gem/ruby/3.0.0/bin
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#808080,bg=italic"
export GOPATH=$HOME/go
export EDITOR=vim
export FZF_DEFAULT_COMMAND='rg --files --follow --no-ignore-vcs --hidden -g "!{node_modules/*,.git/*}"'
export ARCHFLAGS="-arch x86_64" # Compilation flags
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# A bunch of helper functions
vimm() {
    kitty @ set-background-opacity --match pid:$$ 1 
    kitty @ set-colors --match pid:$$ background=#002b36 
    /usr/bin/vim $1
    kitty @ set-background-opacity --match pid:$$ 0.75
    kitty @ set-colors --match pid:$$ background=#00001a 
}

get_gif() {
    gif-for-cli --rows `tput lines` --cols `tput cols` -l 0 $1
}

get_permission_octals() {
    stat -c "%a %n" $1
}

docker_copy_ip() {
   docker inspect $1 | jq -r '.[0].NetworkSettings.Networks[].IPAddress' | xclip -selection clipboard
}

silent_background() {
  if [[ -n $ZSH_VERSION ]]; then  # zsh:  https://superuser.com/a/1285272/365890
    setopt local_options no_notify no_monitor
    # We'd use &| to background and disown, but incompatible with bash, so:
    "$@" &
  elif [[ -n $BASH_VERSION ]]; then  # bash: https://stackoverflow.com/a/27340076/5353461
    { 2>&3 "$@"& } 3>&2 2>/dev/null
  else  # Unknownness - just background it
    "$@" &
  fi
  disown &>/dev/null  # Close STD{OUT,ERR} to prevent whine if job has already completed
}

function ssh_vi_mode() {
   TERM=xterm-color 'ssh' -t $@ 'bash -o vi'
}

# Misc utility commands
# TODO: Make alias to remove latest container | curl --unix-socket /var/run/docker.sock http://localhost/containers/json
alias ssh=ssh_vi_mode
alias copy='xclip -selection clipboard'
alias paste='xclip -selection clipboard -o'
alias gif=get_gif
alias hackerman='gif 15445249'
alias cdc='pwd | copy'
alias cdp='cd $(paste)'
alias fork='kitty &disown && clear'
alias activate='source venv/bin/activate'
alias perms=check_permissions
alias hist="" # eval $(history | fzf -e | sed 's/^ *//g' | sed 's/^[0-9]\+ //' | sed 's/^ *//g')
alias search="ls | fzf"
alias start-nvm="source /usr/share/nvm/init-nvm.sh"
alias vi="/bin/vim"
alias check-cache="sudo nmap -sU -p 53 --script dns-cache-snoop.nse 1.1.1.1"
alias pacman-search="pacman -Slq | fzf -m --preview 'cat <(pacman -Si {1}) <(pacman -Fl {1} | awk \"{print \$2}\")' | xargs -ro sudo pacman -S"
alias yay-search="yay -Slq | fzf -m --preview 'cat <(yay -Si {1}) <(yay -Fl {1} | awk \"{print \$2}\")' | xargs -ro  yay -S"
alias curl-time="curl -w \"@$HOME/Documents/curl/log-time.txt\" -o NUL -s "
alias docker-copy-ip=docker_copy_ip
alias cls="ls -l | awk   '{k=0;for(i=0;i<=8;i++)k+=((substr(\$1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(\"%0o \",k);print}'"
alias yolo='git commit --amend -m "$(curl -s http://whatthecommit.com/index.txt)"'

if [[ -n $SSH_CONNECTION ]]; then
	export TERM=xterm
	alias vi='vim'
else
	alias vim=nvim
	alias clear='clear && kitty @ set-background-opacity --match pid:$$ 0.75'
fi


# Misc configs
bindkey -v # Vi is life
setopt HIST_IGNORE_SPACE # Enable secret commands
setopt noautoremoveslash
xset r rate 200 28 # Gotta go fast

# Initialize stuff
# source <(kubectl completion zsh) # kubectl auto completion
# [[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true # tabtab source for packages

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
