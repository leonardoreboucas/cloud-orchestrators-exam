PREFIX=/tmp/temp_

#Memory
echo $((`cat ${PREFIX}count` + 1)) > ${PREFIX}count
MEM_USED=$(bc -l <<<"`free -b | grep Mem | awk -F' ' '{print $3}'`-`cat ${PREFIX}mem_initial`")
echo $(bc -l <<<"${MEM_USED}+`cat ${PREFIX}mem_amount`") > ${PREFIX}mem_amount

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

#Duration
SPENT=$(bc -l <<<"(`date +%s`-`cat ${PREFIX}time_init`)/60")

echo "DURATION=$SPENT"

echo "$2,$3,$4,$5,$6,$7,$(date +%s),$(printf '%.*f\n' 2 ${CPU}),$(printf '%.*f\n' 2 ${MEM}),$(printf '%.*f\n' 2 ${IO}),$(printf '%.*f\n' 2 ${NET}),$(printf '%.*f\n' 2 ${SPENT})" >> $1
