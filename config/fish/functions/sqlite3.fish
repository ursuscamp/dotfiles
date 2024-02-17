# Defined in - @ line 1
function sqlite3 --description 'alias sqlite3 sqlite3 -header -column'
	command sqlite3 -header -column $argv;
end
