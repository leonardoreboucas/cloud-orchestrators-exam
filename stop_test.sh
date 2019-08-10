#kill -9 $(ps -aux | grep play | awk -F' ' '{print $2}')
pgrep play
pgrep cfy
pgrep terraform
pkill play
pkill cfy
pkill terraform
