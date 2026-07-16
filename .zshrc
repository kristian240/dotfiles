# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Settings
DISABLE_UPDATE_PROMPT="true"
HIST_STAMPS="dd.mm.yyyy"

# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git z starship)

. $ZSH/oh-my-zsh.sh

[ -f ~/.dotfiles/.local ] && . ~/.dotfiles/.local
. ~/.dotfiles/.alias
. ~/.dotfiles/.path


# Constants
export N_PREFIX=$HOME/.n

# openssl
export LDFLAGS="-L/usr/local/Cellar/openssl@1.1/1.1.1i/lib"
export CFLAGS="-I/usr/local/Cellar/openssl@1.1/1.1.1i/include"

# Paths
launchctl setenv PATH $PATH

eval "$(/opt/homebrew/bin/brew shellenv)"
# eval "$(pyenv init --path)"

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
_
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

# 3rd party zsh plugins
. $(brew --prefix)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
. $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
. $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Android SDK (added by Claude)
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
