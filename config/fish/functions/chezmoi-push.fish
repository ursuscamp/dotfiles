function chezmoi-push --description 'chezmoi and git push'
  chezmoi git -- add .; and chezmoi git -- commit -m $argv[1]; and chezmoi git -- push
end
