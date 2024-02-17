function db
    pgcli (impostor2 db $argv[2] $argv[1] --jdbc | sed 's/jdbc://')
end