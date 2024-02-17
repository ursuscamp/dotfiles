function fish_user_keybindings
	fish_vi_key_bindings
	bind -M insert \cg forward-char
	bind -M insert -m default ';;' force-repaint
	bind -M insert \cl 'clear; commandline -f repaint'
	bind -M default \cl 'clear; commandline -f repaint'
end
