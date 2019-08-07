PREFIX=temp_

#Memory
echo $((`cat ${PREFIX}count` + 1)) > ${PREFIX}count
echo $((`cat ${PREFIX}mem_amount` + `free -b | grep Mem | awk -F' ' '{print $3}'`)) > ${PREFIX}mem_amount

#CPU
CPU=$(bc -l <<<"100-`mpstat | grep all | awk -F' ' '{print $13}'`")
echo $(bc -l <<<"${CPU}+`cat ${PREFIX}cpu_amount`") > ${PREFIX}cpu_amount

#IO
IO=$(iotop -n 1 -b | grep "Total DISK READ" | grep "Total DISK WRITE" | awk -F' ' '{print $5+$12}')
echo $(bc -l <<<"${IO}+`cat ${PREFIX}io_amount`") > ${PREFIX}io_amount

#Network
NET=$(iftop -t -p -s 1 | grep "Total send and" | awk -F' ' '{print $6}' | sed -e 's/Kb//')
if [ "$(bc -l <<<"${NET}+`cat ${PREFIX}net_amount`")" != "" ]; then
  echo $(bc -l <<<"${NET}+`cat ${PREFIX}net_amount`") > ${PREFIX}net_amount
fi

#Log
CPU=$(bc -l <<<"`cat ${PREFIX}cpu_amount`/`cat ${PREFIX}count`")
MEM=$(bc -l <<<"`cat ${PREFIX}mem_amount`/`cat ${PREFIX}count`/1024")
IO=$(cat ${PREFIX}io_amount)
NET=$(cat ${PREFIX}net_amount)

echo "$(date +%s),$(printf '%.*f\n' 2 ${CPU}),$(printf '%.*f\n' 2 ${MEM}),$(printf '%.*f\n' 2 ${IO}),$(printf '%.*f\n' 2 ${NET})" >> results
