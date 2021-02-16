# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/kita/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    docker
    docker-compose
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions

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

aws_callback_message() {
    awscurl --service execute-api -X POST -d "hello world" https://lluzted3yi.execute-api.us-east-1.amazonaws.com/Test5/%40connections/$1
}

check_permissions() {
    stat -c "%a %n" $1
}

docker_copy_ip() {
   docker inspect $1 | jq -r '.[0].NetworkSettings.Networks[].IPAddress' | xclip -selection clipboard
}


if [[ -n $SSH_CONNECTION ]]; then
    alias vi='vim'
else
    alias vim=nvim
    alias clear='clear && kitty @ set-background-opacity --match pid:$$ 0.75'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Misc
alias horario='~/Scripts/check_schedule.sh'
alias copy='xclip -selection clipboard'
alias paste='xclip -selection clipboard -o'
alias gif=get_gif
alias hackerman='gif 15445249'
alias cdc='pwd | c'
alias cdv='cd `v`'
alias fork='kitty &disown && clear'
alias activate='source venv/bin/activate'
alias perms=check_permissions
alias hist=""
# eval $(history | fzf -e | sed 's/^ *//g' | sed 's/^[0-9]\+ //' | sed 's/^ *//g')
alias search="ls | fzf"
alias start-nvm="source /usr/share/nvm/init-nvm.sh"
alias vi="/bin/vim"
alias check-cache="sudo nmap -sU -p 53 --script dns-cache-snoop.nse 1.1.1.1"
alias pacman-search="pacman -Slq | fzf -m --preview 'cat <(pacman -Si {1}) <(pacman -Fl {1} | awk \"{print \$2}\")' | xargs -ro sudo pacman -S"
alias yay-search="yay -Slq | fzf -m --preview 'cat <(yay -Si {1}) <(yay -Fl {1} | awk \"{print \$2}\")' | xargs -ro  yay -S"
alias curl-time="curl -w \"@$HOME/Documents/curl/log-time.txt\" -o NUL -s "
alias docker-copy-ip=docker_copy_ip

# Docker [R]emove [A]ll [I]mages
alias 'docker-rai=docker rmi -f $(docker images -a -q)'

# Docker [R]emove [A]ll [C]ontainers
alias 'docker-rac=docker rm $(docker ps -a -q)'

# Docker [S]top [A]ll [C]ontainers
alias 'docker-sac=docker rm $(docker ps -a -q)'


# AWS
alias aws-callback-message=aws_callback_message

# TODO: Make alias to remove latest container | curl --unix-socket /var/run/docker.sock http://localhost/containers/json

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin:$HOME/.local/bin:$HOME/go/bin
export TERM=xterm
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#808080,bg=italic"
export GOPATH=$HOME/go
export EDITOR=vim

bindkey -v

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

cat ~/ASCIIArt/kita
eval `keychain --eval id_rsa`

# Gotta go fast
xset r rate 200 28

# Secret commands
setopt HIST_IGNORE_SPACE

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/opt/anaconda/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/opt/anaconda/etc/profile.d/conda.sh" ]; then
#         . "/opt/anaconda/etc/profile.d/conda.sh"
#     else
#         export PATH="/opt/anaconda/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# <<< conda initialize <<<

# kubectl auto completion
source <(kubectl completion zsh)
