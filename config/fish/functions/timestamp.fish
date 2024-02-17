function timestamp --wraps='date +"%Y-%m-%d %T %z"' --description 'alias timestamp date +"%Y-%m-%d %T %z"'
  date +"%Y-%m-%d %T %z" $argv; 
end
