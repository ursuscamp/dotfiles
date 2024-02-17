function signet --wraps='bitcoin-cli -signet -rpcuser=signet -rpcpassword=signet' --description 'alias signet bitcoin-cli -signet -rpcuser=signet -rpcpassword=signet'
  bitcoin-cli -signet -rpcuser=signet -rpcpassword=signet $argv; 
end
