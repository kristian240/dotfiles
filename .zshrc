# Path to your oh-my-zsh installation.
export ZSH="/Users/kristiandjakovic/.oh-my-zsh"

# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes_
ZSH_THEME="robbyrussell"

# Settings
DISABLE_UPDATE_PROMPT="true"
HIST_STAMPS="dd.mm.yyyy"

# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git z zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# Aliases
alias zshconfig="code ~/.zshrc"
alias gai="git add -i"
alias myip="curl https://ifconfig.co/ip"
alias gcd="git checkout develop"
alias gwork="git log --pretty=\"%ad - %S -  %s.\" --author=\"Kristian Djaković\" --all --since=2023-04-23 --author-date-order"
alias python="python3"
alias y="yarn"


# Constants
export N_PREFIX=$HOME/.n

# TradeLocker AWS
# export AWS_PROFILE=tradelocker_prod
# export KUBECONFIG=~/.kube/tradelocker_prod
# export KUBE_CONFIG_PATH=~/.kube/tradelocker_prod
export AWS_PROFILE=tradelocker_dev
export KUBECONFIG=~/.kube/tradelocker_dev
export KUBE_CONFIG_PATH=~/.kube/tradelocker_dev

# openssl
export LDFLAGS="-L/usr/local/Cellar/openssl@1.1/1.1.1i/lib"
export CFLAGS="-I/usr/local/Cellar/openssl@1.1/1.1.1i/include"

# Paths
export PATH=$N_PREFIX/bin:$PATH
export PATH="/opt/homebrew/Cellar/libpq/13.3/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/usr/local/texlive/2023/bin/universal-darwin:$PATH"
export PATH=$PATH:/Users/kristiandjakovic/.local/bin
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin

launchctl setenv PATH $PATH

# pnpm
export PNPM_HOME="/Users/kristiandjakovic/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

eval "$(starship init zsh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
# eval "$(pyenv init --path)"

PATH="/Users/kristiandjakovic/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/kristiandjakovic/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/kristiandjakovic/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/kristiandjakovic/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/kristiandjakovic/perl5"; export PERL_MM_OPT;


# CUSTOM COMMAND HANDLER

# Function to handle unknown commands
function handle_unknown_command() {
  local command="$1"
  shift
  local args="$@"
  local mappings_file="$HOME/.command_mappings.json"
  local current_dir=$(pwd)

  # Ensure the mappings file exists
  if [[ ! -f "$mappings_file" ]]; then
    echo '{}' > "$mappings_file"
  fi

  # Load the mappings for the current directory
  local dir_mappings=$(jq -r --arg dir "$current_dir" '.[$dir] // {}' "$mappings_file")

  # Check if the command has been mapped
  local mapped_command=$(echo "$dir_mappings" | jq -r --arg cmd "$command" '.[$cmd] // empty')

  if [[ -n "$mapped_command" ]]; then
    # If the command exists, execute it
    eval "$mapped_command $args"
  else
    # If the command does not exist, prompt the user for a mapping
    echo "Command '$command' not found. Please provide the command to map it to:"
    read -r mapped_command

    # Update the JSON with the new mapping
    updated_mappings=$(jq --arg dir "$current_dir" --arg cmd "$command" --arg map_cmd "$mapped_command" \
      '.[$dir][$cmd] = $map_cmd' "$mappings_file")
    echo "$updated_mappings" > "$mappings_file"

    echo "Command '$command' mapped to '$mapped_command' for this directory."

    # Execute the mapped command
    eval "$mapped_command $args"
  fi
}

# Load custom unknown command handler
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit
function command_not_found_handler() {
  handle_unknown_command "$@"
}

# CUSTOM COMMAND HANDLER END