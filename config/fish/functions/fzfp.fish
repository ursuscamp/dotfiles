function fzfp
	fzf --preview 'head -100 {}' $argv;
end
