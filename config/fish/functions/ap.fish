function ap --wraps='set -x AWS_PROFILE (aws configure list-profiles | fzf)' --wraps='set -x AWS_PROFILE (aws configure list-profiles | sort | fzf)' --description 'alias ap=set -x AWS_PROFILE (aws configure list-profiles | sort | fzf)'
  set -x AWS_PROFILE (aws configure list-profiles | sort | fzf) $argv
        
end
