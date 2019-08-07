kill -9 $(ps -aux | grep play | awk -F' ' '{print $2}')
