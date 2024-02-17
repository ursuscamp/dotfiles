# Defined in - @ line 1
function lzconfig --description 'alias lzconfig set -xg KUBECONFIG /Users/rbreen/.kube/lz_config'
	set -xg KUBECONFIG /Users/rbreen/.kube/lz_config $argv;
end
