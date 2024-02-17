function gpnb --description 'push current git branch as new remote branch'
    git push --set-upstream origin (git branch --show-current)
end