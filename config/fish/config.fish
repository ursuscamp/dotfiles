set -xg AWS_CONFIG_FILE ~/.aws/config-i2
set -xg AWS_CREDENTIAL_PROFILES_FILE ~/.aws/config-i2-java
set -xg KUBECONFIG ~/.kube/config-eks
set -xg AWS_PROFILE ah-nonprod-pmp@hd-pmp-developer

set -xg PATH $PATH $HOME/bin \
  .bin \
  /opt/homebrew/bin \
  /Users/rbreen/.local/bin \
  /Users/rbreen/Library/Python/3.6/bin \
  /Users/rbreen/Library/Python/3.7/bin \
  ~/.cargo/bin

set -x EDITOR "nvim"

set -x FZF_DEFAULT_COMMAND 'fd --type f'
set -x FZF_DEFAULT_OPTS '--multi --bind ctrl-y:accept'

set -x PGDATA $HOME/.local/share/postgres

if status --is-interactive
	# Erase the greeting and show something more interesting.
	set fish_greeting
	begin
	  set choice (random choice \
	    "Hello, Dave." \
	    "To boldly go..." \
	    "May the force be with you." \
	    "Do, or do not." \
	    "Unleash the kraken." \
	    "To infinity and beyond!" \
	    "Ron Paul 2024" \
	    "The cake is a lie." \
	    "I'm sorry, Dave. I'm afraid I can't do that." \
	    "I am Groot." \
	    "There is no second best." \
	    )
	  # If figlet exists, show the message/quote in figlet.
	  set_color green
	  if command -sq figlet
	    figlet $choice
	  else
	    echo \"$choice\"
	  end
	  set_color blue
	  date
	  set_color normal
	end

	starship init fish | source
	fzf --fish | source
end
