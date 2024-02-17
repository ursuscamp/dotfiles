function ksc --wraps=kubectl\ config\ use-context\ \(kubectl\ config\ get-contexts\ \|\ awk\ \'\{print\ \$1\}\'\ \|\ fzf\) --description alias\ ksc=kubectl\ config\ use-context\ \(kubectl\ config\ get-contexts\ \|\ awk\ \'\{print\ \$1\}\'\ \|\ fzf\)
  kubectl config use-context (kubectl config get-contexts | awk '{print $1}' | fzf) $argv
        
end
