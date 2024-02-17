function regtest --wraps='bitcoin-cli -regtest -rpcuser=regtest -rpcpassword=regtest' --description 'alias regtest bitcoin-cli -regtest -rpcuser=regtest -rpcpassword=regtest'
  bitcoin-cli -regtest -rpcuser=regtest -rpcpassword=regtest $argv; 
end
